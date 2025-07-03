import 'package:flutter/material.dart';
import 'package:mycrochetbag/data/services/user_information_service.dart';
import 'package:mycrochetbag/ui/customer/customer_checkout/widget/adress_section.dart';
import 'package:provider/provider.dart';
import 'package:mycrochetbag/domain/model/Address.dart';
import 'package:mycrochetbag/domain/model/User.dart';
import 'package:mycrochetbag/data/services/auth_service.dart';

class CustomerAddressManagementScreen extends StatefulWidget {
  const CustomerAddressManagementScreen({super.key});

  @override
  State<CustomerAddressManagementScreen> createState() =>
      _AddressManagementScreenState();
}

class _AddressManagementScreenState
    extends State<CustomerAddressManagementScreen> {
  final GlobalKey<AddressSectionState> _addressSectionKey =
      GlobalKey<AddressSectionState>();
  final UserInformationService _userInformationService =
      UserInformationService();

  User? _user;
  Address? _currentAddress;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final authService = Provider.of<AuthServices>(context, listen: false);
    final userId = authService.currentUser?.uid;

    if (userId == null) {
      setState(() => _loading = false);
      return;
    }

    try {
      final userData = await _userInformationService.fetchUserById(userId);
      if (userData != null) {
        setState(() {
          _user = User.fromMap(userData.toMap());
          _currentAddress = _user?.address;
          print(_currentAddress);
          if (_currentAddress != null &&
              (_currentAddress!.fullName.trim().isEmpty)) {
            _currentAddress!.fullName =
                '${_user?.firstName ?? ''} ${_user?.lastName ?? ''}';
          }

          _loading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => _loading = false);
    }
  }

  Future<void> _saveAddress() async {
    if (_addressSectionKey.currentState?.validateFields() != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final authService = Provider.of<AuthServices>(context, listen: false);
    final userId = authService.currentUser?.uid;

    if (userId == null) return;

    try {
      final addressData = _addressSectionKey.currentState!.getAddressData();
      final address = _addressSectionKey.currentState!.getAddress();

      // Save to Firestore
      await _userInformationService.updateUserAddress(userId, address);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Address saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save address: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Address'),
        centerTitle: true,
        elevation: 0,
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    AddressSection(
                      key: _addressSectionKey,
                      initialAddress: _currentAddress,
                      user: _user,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _saveAddress,
                        child: const Text('Save Address'),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
