import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PriceDisplayWidget extends StatelessWidget {
  final int priceInIDR;
  final bool showOtherCurrencies;

  static const double USD_RATE = 0.000064; // 1 IDR = 0.000064 USD
  static const double SGD_RATE = 0.000087; // 1 IDR = 0.000087 SGD

  const PriceDisplayWidget({
    super.key,
    required this.priceInIDR,
    this.showOtherCurrencies = false,
  });

  @override
  Widget build(BuildContext context) {
    final idrFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          idrFormatter.format(priceInIDR),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        if (showOtherCurrencies) ...[
          const SizedBox(height: 8),
          Text(
            '≈ \$${(priceInIDR * USD_RATE).toStringAsFixed(2)}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          Text(
            '≈ S\$${(priceInIDR * SGD_RATE).toStringAsFixed(2)}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ],
    );
  }
}
