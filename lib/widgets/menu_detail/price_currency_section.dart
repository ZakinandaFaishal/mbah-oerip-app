import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../theme.dart';

class PriceCurrencySection extends StatelessWidget {
  final int priceInIDR; // was double
  const PriceCurrencySection({super.key, required this.priceInIDR});

  String _formatAmount(double amount, String currency) {
    final sym = CartProvider.currencySymbols[currency] ?? '';
    if (currency == 'IDR') return '$sym ${amount.toStringAsFixed(0)}';
    if (currency == 'JPY') return '$sym${amount.toStringAsFixed(0)}';
    return '$sym${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final converted = cart.convertFromIDR(priceInIDR);
    final convertedText = _formatAmount(converted, cart.selectedCurrency);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: cart.selectedCurrency,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                items: CartProvider.currencyRates.keys.map((c) {
                  final sym = CartProvider.currencySymbols[c] ?? '';
                  return DropdownMenuItem(value: c, child: Text('$c ($sym)'));
                }).toList(),
                onChanged: (v) => v != null ? cart.setCurrency(v) : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            convertedText,
            style: const TextStyle(
              color: AppTheme.primaryOrange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
