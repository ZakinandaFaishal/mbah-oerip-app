import 'package:flutter/material.dart';
import '../../providers/cart_provider.dart';

class CurrencySelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const CurrencySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Mata Uang',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: CartProvider.currencyRates.keys.map((c) {
              final sym = CartProvider.currencySymbols[c] ?? '';
              return DropdownMenuItem(value: c, child: Text('$c ($sym)'));
            }).toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}
