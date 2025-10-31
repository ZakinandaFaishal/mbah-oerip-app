import 'package:flutter/material.dart';

class CartEmptyState extends StatelessWidget {
  final VoidCallback onAddMenu;
  const CartEmptyState({super.key, required this.onAddMenu});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 60),
        Icon(
          Icons.shopping_bag_outlined,
          size: 72,
          color: Colors.grey.shade400,
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'Keranjang kosong',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 6),
        const Center(child: Text('Tambahkan menu untuk melanjutkan')),
        const SizedBox(height: 24),
        Center(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.shopping_cart),
            onPressed: onAddMenu,
            label: const Text('Tambah Menu'),
          ),
        ),
      ],
    );
  }
}
