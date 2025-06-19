import 'package:flutter/material.dart';

enum PaymentMethod { card, fpx }

class PaymentMethodSection extends StatefulWidget {
  final Function(PaymentMethod) onPaymentMethodChanged;

  const PaymentMethodSection({super.key, required this.onPaymentMethodChanged});

  @override
  PaymentMethodSectionState createState() => PaymentMethodSectionState();
}

class PaymentMethodSectionState extends State<PaymentMethodSection> {
  PaymentMethod selectedPayment = PaymentMethod.fpx;

  PaymentMethod getSelectedPaymentMethod() {
    return selectedPayment;
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
            'Payment Method',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // FPX Option
          GestureDetector(
            onTap: () {
              setState(() {
                selectedPayment = PaymentMethod.fpx;
              });
              widget.onPaymentMethodChanged(selectedPayment);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      selectedPayment == PaymentMethod.fpx
                          ? Colors.blue
                          : Colors.grey[300]!,
                  width: selectedPayment == PaymentMethod.fpx ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color:
                    selectedPayment == PaymentMethod.fpx
                        ? Colors.blue.withOpacity(0.05)
                        : Colors.white,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 25,
                    decoration: BoxDecoration(
                      color:
                          selectedPayment == PaymentMethod.fpx
                              ? Colors.blue[100]
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.account_balance,
                      size: 16,
                      color:
                          selectedPayment == PaymentMethod.fpx
                              ? Colors.blue[700]
                              : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'FPX',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          selectedPayment == PaymentMethod.fpx
                              ? Colors.blue
                              : Colors.black,
                    ),
                  ),
                  const Spacer(),
                  if (selectedPayment == PaymentMethod.fpx)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.blue,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Card Option
          GestureDetector(
            onTap: () {
              setState(() {
                selectedPayment = PaymentMethod.card;
              });
              widget.onPaymentMethodChanged(selectedPayment);
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color:
                      selectedPayment == PaymentMethod.card
                          ? Colors.blue
                          : Colors.grey[300]!,
                  width: selectedPayment == PaymentMethod.card ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
                color:
                    selectedPayment == PaymentMethod.card
                        ? Colors.blue.withOpacity(0.05)
                        : Colors.white,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 25,
                    decoration: BoxDecoration(
                      color:
                          selectedPayment == PaymentMethod.card
                              ? Colors.blue[100]
                              : Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.credit_card,
                      size: 16,
                      color:
                          selectedPayment == PaymentMethod.card
                              ? Colors.blue[700]
                              : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Credit/Debit Card',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color:
                          selectedPayment == PaymentMethod.card
                              ? Colors.blue
                              : Colors.black,
                    ),
                  ),
                  const Spacer(),
                  if (selectedPayment == PaymentMethod.card)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.blue,
                      size: 20,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
