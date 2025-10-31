import 'package:flutter/material.dart';
import '../../theme.dart';

class QtyAddToCartBar extends StatelessWidget {
  final int qty;
  final VoidCallback? onDec;
  final VoidCallback onInc;
  final VoidCallback onAdd;

  const QtyAddToCartBar({
    super.key,
    required this.qty,
    required this.onDec,
    required this.onInc,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Qty Stepper
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: onDec,
                icon: const Icon(Icons.remove),
                constraints: const BoxConstraints(),
              ),
              Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold)),
              IconButton(
                onPressed: onInc,
                icon: const Icon(Icons.add),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Add to cart
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_shopping_cart),
            label: const Text('Tambah ke Keranjang'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              backgroundColor: AppTheme.primaryOrange,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
