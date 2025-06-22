import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardInformationSection extends StatefulWidget {
  const CardInformationSection({super.key});

  @override
  CardInformationSectionState createState() => CardInformationSectionState();
}

class CardInformationSectionState extends State<CardInformationSection> {
  final _cardHolderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryDateController = TextEditingController();
  final _securityCodeController = TextEditingController();

  @override
  void dispose() {
    _cardHolderController.dispose();
    _cardNumberController.dispose();
    _expiryDateController.dispose();
    _securityCodeController.dispose();
    super.dispose();
  }

  bool validateFields() {
    return _cardHolderController.text.isNotEmpty &&
        _cardNumberController.text.isNotEmpty &&
        _expiryDateController.text.isNotEmpty &&
        _securityCodeController.text.isNotEmpty;
  }

  Map<String, String> getCardData() {
    return {
      'cardHolder': _cardHolderController.text,
      'cardNumber': _cardNumberController.text,
      'expiryDate': _expiryDateController.text,
      'securityCode': _securityCodeController.text,
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
            'Card Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Card Holder
          _buildInputField(
            label: 'Card Holder *',
            controller: _cardHolderController,
            hintText: 'John Doe',
          ),
          const SizedBox(height: 16),

          // Card Number
          _buildInputField(
            label: 'Card Number *',
            controller: _cardNumberController,
            hintText: '0000-0000-0000-0000',
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // Expiry Date and Security Code
          Row(
            children: [
              Expanded(
                child: _buildInputField(
                  label: 'Expiry Date *',
                  controller: _expiryDateController,
                  hintText: 'MM/YY',
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5), // Max length "MM/YY"
                    _expiryDateFormatter(),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildInputField(
                  label: 'Security Code *',
                  controller: _securityCodeController,
                  hintText: 'CVV',
                  keyboardType: TextInputType.number,
                  obscureText: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
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
          obscureText: obscureText,
          inputFormatters: inputFormatters, // Use the inputFormatters parameter
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

  // Custom TextInputFormatter for Expiry Date (MM/YY)
  TextInputFormatter _expiryDateFormatter() {
    return TextInputFormatter.withFunction((oldValue, newValue) {
      String newText = newValue.text;

      // Insert a slash after the second digit
      if (newText.length > 2) {
        newText = newText.substring(0, 2) + '/' + newText.substring(2);
      }

      // Limit to "MM/YY" format, maximum 5 characters
      if (newText.length > 5) {
        newText = newText.substring(0, 5);
      }

      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    });
  }
}
