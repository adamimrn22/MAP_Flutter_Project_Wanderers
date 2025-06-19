import 'package:flutter/material.dart';

class FpxSection extends StatefulWidget {
  const FpxSection({super.key});

  @override
  FpxSectionState createState() => FpxSectionState();
}

class FpxSectionState extends State<FpxSection> {
  String? selectedBank;

  final List<Map<String, String>> banks = [
    {'name': 'Maybank', 'code': 'fpx_mb2u'},
    {'name': 'CIMB Bank', 'code': 'fpx_cimbclicks'},
    {'name': 'Public Bank', 'code': 'fpx_pbb'},
    {'name': 'RHB Bank', 'code': 'fpx_pbb'},
    {'name': 'Hong Leong Bank', 'code': 'fpx_hlb'},
    {'name': 'AmBank', 'code': 'fpx_amb'},
    {'name': 'UOB Bank', 'code': 'fpx_uob'},
    {'name': 'Bank Islam', 'code': 'fpx_bimb'},
    {'name': 'BSN', 'code': 'fpx_bsn'},
    {'name': 'OCBC Bank', 'code': 'fpx_ocbc'},
  ];

  bool validateFields() {
    return selectedBank != null && selectedBank!.isNotEmpty;
  }

  Map<String, String> getFpxData() {
    return {
      'selectedBank': selectedBank ?? '',
      'bankCode':
          banks.firstWhere(
            (bank) => bank['name'] == selectedBank,
            orElse: () => {'code': ''},
          )['code'] ??
          '',
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
            'Select Your Bank',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Bank Selection Dropdown
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedBank,
                hint: const Text(
                  'Choose your bank',
                  style: TextStyle(color: Colors.grey),
                ),
                isExpanded: true,
                items:
                    banks.map((bank) {
                      return DropdownMenuItem<String>(
                        value: bank['name'],
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.account_balance,
                                size: 16,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              bank['name']!,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedBank = newValue;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          // FPX Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You will be redirected to your bank\'s secure login page to complete the payment.',
                    style: TextStyle(color: Colors.blue[700], fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
