import 'package:flutter/material.dart';
import '../../theme.dart';

class BottomCheckoutBar extends StatelessWidget {
  final String totalText;
  final VoidCallback onCheckout;
  const BottomCheckoutBar({
    super.key,
    required this.totalText,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total', style: TextStyle(color: Colors.grey)),
                  Text(
                    totalText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onCheckout,
                child: const Text(
                  'Checkout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
