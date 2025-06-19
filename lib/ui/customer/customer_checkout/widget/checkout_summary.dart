import 'package:flutter/material.dart';
import 'package:mycrochetbag/data/model/price_summary.dart';

class CheckoutSummary extends StatelessWidget {
  final PriceSummary priceSummary;
  final VoidCallback onPayPressed;

  const CheckoutSummary({
    super.key,
    required this.priceSummary,
    required this.onPayPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            _buildSummaryRow(
              'Subtotal',
              'RM ${priceSummary.subtotal.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),

            _buildSummaryRow(
              'Delivery Fee',
              'RM ${priceSummary.deliveryFee.toStringAsFixed(2)}',
              isGrey: true,
            ),
            const SizedBox(height: 8),

            _buildSummaryRow(
              'Processing Fee',
              'RM ${priceSummary.processingFee.toStringAsFixed(2)}',
              isGrey: true,
            ),
            const SizedBox(height: 16),

            const Divider(),
            const SizedBox(height: 8),

            _buildSummaryRow(
              'Total',
              'RM ${priceSummary.total.toStringAsFixed(2)}',
              isBold: true,
              fontSize: 18,
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onPayPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Pay Now',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isGrey = false,
    bool isBold = false,
    double fontSize = 14,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: isGrey ? Colors.grey[600] : Colors.black,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
