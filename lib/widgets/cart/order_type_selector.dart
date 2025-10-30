import 'package:flutter/material.dart';
import '../../providers/cart_provider.dart';
import '../../theme.dart';

class OrderTypeSelector extends StatelessWidget {
  final OrderType selected;
  final ValueChanged<OrderType> onChanged;
  const OrderTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    Widget chip(String label, IconData icon, OrderType type) {
      final bool active = selected == type;
      return Expanded(
        child: InkWell(
          onTap: () => onChanged(type),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: active ? AppTheme.primaryOrange : Colors.white,
              border: Border.all(color: AppTheme.primaryOrange, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: active ? Colors.white : AppTheme.primaryOrange,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: active ? Colors.white : AppTheme.primaryOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        chip('Dine-in', Icons.restaurant, OrderType.dineIn),
        const SizedBox(width: 8),
        chip('Delivery', Icons.two_wheeler, OrderType.delivery),
        const SizedBox(width: 8),
        chip('Pickup', Icons.shopping_bag, OrderType.pickup),
      ],
    );
  }
}
