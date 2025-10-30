import 'package:flutter/material.dart';
import '../../theme.dart';

class CartItemCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String priceText;
  final String totalText;
  final int quantity;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.priceText,
    required this.totalText,
    required this.quantity,
    required this.onInc,
    required this.onDec,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image_not_supported),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        priceText,
                        style: const TextStyle(
                          color: AppTheme.primaryOrange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // qty
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: quantity > 1 ? onDec : null,
                        icon: const Icon(Icons.remove),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                      Text(
                        '$quantity',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        onPressed: onInc,
                        icon: const Icon(Icons.add),
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.all(8),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  totalText,
                  style: const TextStyle(
                    color: AppTheme.primaryOrange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
