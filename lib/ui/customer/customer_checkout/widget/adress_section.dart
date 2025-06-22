import 'package:flutter/material.dart';

class AddressSection extends StatefulWidget {
  const AddressSection({super.key});

  @override
  AddressSectionState createState() => AddressSectionState();
}

class AddressSectionState extends State<AddressSection> {
  final _address1Controller = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _postcodeController = TextEditingController();

  String? _selectedState;

  final List<String> _malaysianStates = [
    'Johor',
    'Kedah',
    'Kelantan',
    'Kuala Lumpur',
    'Labuan',
    'Melaka',
    'Negeri Sembilan',
    'Pahang',
    'Penang',
    'Perak',
    'Perlis',
    'Putrajaya',
    'Sabah',
    'Sarawak',
    'Selangor',
    'Terengganu',
  ];

  @override
  void dispose() {
    _address1Controller.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _postcodeController.dispose();
    super.dispose();
  }

  bool validateFields() {
    return _address1Controller.text.isNotEmpty &&
        _cityController.text.isNotEmpty &&
        _selectedState != null &&
        _postcodeController.text.isNotEmpty;
  }

  Map<String, String> getAddressData() {
    return {
      'address1': _address1Controller.text,
      'address2': _address2Controller.text,
      'city': _cityController.text,
      'state': _selectedState ?? '',
      'postcode': _postcodeController.text,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Delivery Address',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Address Line 1
          _buildInputField(
            label: 'Address Line 1 *',
            controller: _address1Controller,
            hintText: 'Enter your street address',
          ),
          const SizedBox(height: 16),

          // Address Line 2
          _buildInputField(
            label: 'Address Line 2 (Optional)',
            controller: _address2Controller,
            hintText: 'Apartment, suite, unit, building, floor, etc.',
          ),
          const SizedBox(height: 16),

          // City
          _buildInputField(
            label: 'City *',
            controller: _cityController,
            hintText: 'Enter city',
          ),
          const SizedBox(height: 16),

          // State (replacing Postcode)
          // Postcode
          _buildInputField(
            label: 'Postcode *',
            controller: _postcodeController,
            hintText: '12345',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          _buildStateClickableField(context),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.blue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStateClickableField(BuildContext context) {
    return GestureDetector(
      onTap: () => _showStateSelectionBottomSheet(context),
      child: AbsorbPointer(
        // Disables interactions with the underlying text field
        child: _buildInputField(
          label: 'State *',
          controller: TextEditingController(
            text: _selectedState ?? 'Select State',
          ),
          hintText: 'Select state',
        ),
      ),
    );
  }

  void _showStateSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView.builder(
          itemCount: _malaysianStates.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(_malaysianStates[index]),
              onTap: () {
                setState(() {
                  _selectedState = _malaysianStates[index];
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }
}
