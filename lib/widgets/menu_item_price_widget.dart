import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MenuItemPriceWidget extends StatelessWidget {
  final int priceInIDR;

  // Static conversion rates (as of October 2023)
  static const double USD_RATE = 0.000064; // 1 IDR = 0.000064 USD
  static const double SGD_RATE = 0.000087; // 1 IDR = 0.000087 SGD

  const MenuItemPriceWidget({super.key, required this.priceInIDR});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Harga",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            // IDR Price
            Text(
              NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              ).format(priceInIDR),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const Divider(height: 24),
            const Text(
              "Konversi ke mata uang lain:",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'USD: \$${(priceInIDR * USD_RATE).toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'SGD: S\$${(priceInIDR * SGD_RATE).toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
