import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:mycrochetbag/data/model/price_summary.dart';
import 'package:mycrochetbag/data/services/auth_service.dart';
import 'package:mycrochetbag/data/services/user_information_service.dart';
import 'package:mycrochetbag/domain/model/CartItem.dart';
import 'package:mycrochetbag/domain/model/User.dart';
import 'package:mycrochetbag/ui/customer/customer_checkout/viewmodel/process_payment_viewmodel.dart';
import 'package:mycrochetbag/ui/customer/customer_checkout/widget/adress_section.dart';
import 'package:mycrochetbag/ui/customer/customer_checkout/widget/payment_method_section.dart';
import 'package:mycrochetbag/ui/customer/customer_checkout/widget/card_information_section.dart';
import 'package:mycrochetbag/ui/customer/customer_checkout/widget/fpx_section.dart';
import 'package:mycrochetbag/ui/customer/customer_checkout/widget/checkout_summary.dart';

class CheckoutScreen extends StatefulWidget {
  final PriceSummary priceSummary;
  final List<CartItem> cartItems;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.priceSummary,
  });

  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Controllers
  final GlobalKey<AddressSectionState> _addressKey =
      GlobalKey<AddressSectionState>();
  final GlobalKey<CardInformationSectionState> _cardKey =
      GlobalKey<CardInformationSectionState>();
  final GlobalKey<FpxSectionState> _fpxKey = GlobalKey<FpxSectionState>();
  final GlobalKey<PaymentMethodSectionState> _paymentMethodKey =
      GlobalKey<PaymentMethodSectionState>();

  PaymentMethod selectedPaymentMethod = PaymentMethod.fpx;
  bool _isProcessingPayment = false;
  bool _isLoadingUser = true;

  final AppLinks _appLinks = AppLinks();
  StreamSubscription? _deepLinkSubscription;

  User? _currentUser;
  final UserInformationService _userService = UserInformationService();
  final AuthServices _authService = AuthServices();

  @override
  void initState() {
    super.initState();
    _initDeepLinkListener();
    _loadCurrentUser();
  }

  @override
  void dispose() {
    _deepLinkSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userId = _authService.getCurrentUserId();
      if (userId != null) {
        final user = await _userService.fetchUserById(userId);
        setState(() {
          _currentUser = user;
          _isLoadingUser = false;
        });
      } else {
        setState(() {
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      print('Error loading user: $e');
      setState(() {
        _isLoadingUser = false;
      });
    }
  }

  void _initDeepLinkListener() {
    _deepLinkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        _handleDeepLink(uri);
      },
      onError: (err) {
        print('Deep link error: $err');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to process payment link')),
        );
      },
    );
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'com.example.mycrochetbag' &&
        uri.host == 'payment-result') {
      final status = uri.queryParameters['status'];

      print('Payment status: $status');

      if (status == 'authorised') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment Successful'),
            backgroundColor: Colors.green, // Add this line for green background
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment failed: $status')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body:
          _isLoadingUser
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AddressSection(
                            key: _addressKey,
                            initialAddress: _currentUser?.address,
                            user: _currentUser,
                          ),
                          const SizedBox(height: 24),
                          PaymentMethodSection(
                            key: _paymentMethodKey,
                            onPaymentMethodChanged: (PaymentMethod method) {
                              setState(() {
                                selectedPaymentMethod = method;
                              });
                            },
                          ),
                          const SizedBox(height: 24),

                          // Conditional rendering based on selected payment method
                          if (selectedPaymentMethod == PaymentMethod.card)
                            CardInformationSection(key: _cardKey)
                          else if (selectedPaymentMethod == PaymentMethod.fpx)
                            FpxSection(key: _fpxKey),
                        ],
                      ),
                    ),
                  ),
                  CheckoutSummary(
                    priceSummary: widget.priceSummary,
                    onPayPressed: _processPayment,
                  ),
                ],
              ),
    );
  }

  void _processPayment() async {
    if (_isProcessingPayment) {
      print('Payment already in progress');
      return;
    }

    setState(() {
      _isProcessingPayment = true;
    });

    try {
      // Validate address
      if (!_addressKey.currentState!.validateFields()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill in all required address fields'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_currentUser != null) {
        final address = _addressKey.currentState!.getAddress();
        await _userService.updateUserAddress(_currentUser!.id!, address);
      }

      // Validate payment information based on selected method
      bool isPaymentValid = false;
      Map<String, dynamic> paymentData = {};

      if (selectedPaymentMethod == PaymentMethod.card) {
        isPaymentValid = _cardKey.currentState!.validateFields();
        if (isPaymentValid) {
          paymentData = {
            'method': 'card',
            'data': _cardKey.currentState!.getCardData(),
          };
        }
      } else if (selectedPaymentMethod == PaymentMethod.fpx) {
        isPaymentValid = _fpxKey.currentState!.validateFields();
        if (isPaymentValid) {
          paymentData = {
            'method': 'fpx',
            'data': _fpxKey.currentState!.getFpxData(),
          };
        }
      }

      if (!isPaymentValid) {
        String errorMessage =
            selectedPaymentMethod == PaymentMethod.card
                ? 'Please fill in all payment information'
                : 'Please select your bank for FPX payment';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
        return;
      }

      // Get address data
      final addressData = _addressKey.currentState!.getAddressData();

      List<Map<String, dynamic>> orders = [];
      for (var cartItem in widget.cartItems) {
        orders.add({
          'itemId': cartItem.productId,
          'id': cartItem.id,
          'name': cartItem.name,
          'size': cartItem.size,
          'color': cartItem.color,
          'quantity': cartItem.quantity,
          'price': cartItem.price,
        });
      }

      // Print orders as a JSON-like structure (for debugging purposes)
      print('Orders: $orders');
      print('paymentData: $paymentData');

      // Initialize the ViewModel
      final viewModel = ProcessPaymentViewModel();

      await viewModel.pay(
        paymentData: paymentData,
        addressData: addressData,
        orders: orders,
        totalAmount: widget.priceSummary.total,
        context: context,
      );
    } catch (error) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingPayment = false;
        });
      }
    }
  }
}
