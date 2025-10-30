import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/menu_item.dart';
import 'menu_card.dart';

class MenuGrid extends StatelessWidget {
  final List<MenuItem> items;
  final NumberFormat idr;
  final ValueChanged<MenuItem> onItemTap;
  final ValueChanged<MenuItem> onAddCart;

  const MenuGrid({
    super.key,
    required this.items,
    required this.idr,
    required this.onItemTap,
    required this.onAddCart,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, idx) {
        final item = items[idx];
        return MenuCard(
          item: item,
          idr: idr,
          onTap: () => onItemTap(item),
          onAddCart: () => onAddCart(item),
        );
      },
    );
  }
}
