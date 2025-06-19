import 'dart:convert';
import 'dart:convert' as convert;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:mycrochetbag/data/services/auth_service.dart';
import 'package:mycrochetbag/routing/routes.dart';
import 'package:url_launcher/url_launcher.dart';

class ProcessPaymentViewModel {
  static const baseUrl = "https://crochetbag-payment-service.vercel.app";
  // static const baseUrl = "http://192.168.248.148:3000";
  bool _isProcessing = false;

  Future<void> pay({
    required Map<String, dynamic> paymentData,
    required Map<String, dynamic> addressData,
    required List<Map<String, dynamic>> orders,
    required double totalAmount,
    required BuildContext context,
  }) async {
    String url;
    Map<String, dynamic> requestData;

    if (_isProcessing) {
      print('Payment already in progress, ignoring duplicate call');
      return;
    }

    _isProcessing = true;

    final currentUser = AuthServices().getCurrentUserId();

    // Decide which API endpoint to call based on payment method
    if (paymentData['method'] == 'fpx') {
      // FPX Payment Data Structure
      url = '$baseUrl/api/payment/payByFPX';

      requestData = {
        'userId': currentUser,
        'address': addressData,
        'orders': orders,
        'issuer': paymentData['data']['bankCode'],
      };
      print('Request Data: ${jsonEncode(requestData)}');

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: convert.jsonEncode(requestData),
      );

      final data = convert.jsonDecode(response.body);
      print('Adyen FPX Response: $data');

      if (data['resultCode'] == 'RedirectShopper' &&
          data['action']?['url'] != null) {
        String redirectUrl = data['action']['url'];

        // Clean and encode the URL properly
        try {
          // Parse the URI to validate it
          final uri = Uri.parse(redirectUrl);

          // Try different launch approaches
          bool launched = false;

          // Method 1: Try external application first
          if (await canLaunchUrl(uri)) {
            launched = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            print('External launch result: $launched');
          }

          // Method 2: Fallback to platform default
          if (!launched) {
            print('Trying platform default...');
            launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
            print('Platform default result: $launched');
          }

          // Method 3: Last resort - in-app web view
          if (!launched) {
            print('Trying in-app web view...');
            launched = await launchUrl(uri, mode: LaunchMode.inAppWebView);
            print('In-app webview result: $launched');
          }

          if (!launched) {
            throw 'All launch methods failed';
          }
        } catch (e) {
          print('URL parsing/launching error: $e');
          throw 'Could not launch FPX URL: $e';
        } finally {
          _isProcessing = false;
        }
      } else {
        print('Unexpected response structure: $data');
        throw 'Unexpected Adyen response';
      }
    } else {
      // Card Payment Data Structure
      url = '$baseUrl/api/payment/payByCard';
      String expiryDate = paymentData['data']['expiryDate'];
      List<String> expiryParts = expiryDate.split('/');

      // Now you have the month and year
      String expiryMonth = expiryParts[0]; // '03'
      String expiryYear = expiryParts[1]; // '30'

      // Build the request data
      var requestData = {
        'userId': currentUser,
        'address': addressData,
        'orders': orders,
        'paymentType': 'card',
        'paymentMethod': {
          'type': 'scheme',
          'encryptedCardNumber': paymentData['data']['encryptedCardNumber'],
          'encryptedExpiryMonth': expiryMonth,
          'encryptedExpiryYear': expiryYear,
          'encryptedSecurityCode': paymentData['data']['encryptedSecurityCode'],
        },
      };

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: {'Content-Type': 'application/json'},
          body: convert.jsonEncode(requestData),
        );

        if (response.statusCode == 200) {
          final data = convert.jsonDecode(response.body);
          print('Card Payment Response Data: $data');
          final paymentResponse = data['paymentResponse'];
          final resultCode = paymentResponse?['resultCode'];

          print('ResultCode: $resultCode');

          // Check if payment was successful
          if (resultCode == 'Authorised') {
            // Payment successful - show success snackbar and navigate home
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Payment completed successfully!'),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );

            // Navigate to customer home
            context.go(Routes.customerHome);
          } else {
            // Payment failed
            String errorMessage =
                data['refusalReason'] ?? 'Payment was declined';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Payment failed: $errorMessage'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          // HTTP error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment service error. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        _isProcessing = false;
      }
    }
  }
}
