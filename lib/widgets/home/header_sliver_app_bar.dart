import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../theme.dart';
import 'home_search_bar.dart';
import '../../screens/cart_screen.dart';

class HeaderSliverAppBar extends StatelessWidget {
  const HeaderSliverAppBar({
    super.key,
    required this.fullName,
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
    required this.onDirectionTap,
  });

  final String fullName;
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;
  final VoidCallback onDirectionTap;

  @override
  Widget build(BuildContext context) {
    final cartCount = context.watch<CartProvider>().cartCount;

    return SliverAppBar(
      pinned: true,
      elevation: 0.5,
      backgroundColor: Colors.white,
      expandedHeight: 120,
      leadingWidth: 0,
      leading: const SizedBox.shrink(),
      title: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.primaryOrange.withOpacity(.15),
            child: const Icon(
              Icons.restaurant_menu,
              color: AppTheme.primaryOrange,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Hai, $fullName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            IconButton(
              icon: const Icon(
                Icons.shopping_cart_outlined,
                color: AppTheme.primaryOrange,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
            ),
            if (cartCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$cartCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(16, 80, 16, 0),
          color: Colors.white,
          child: HomeSearchBar(
            onDirectionTap: onDirectionTap,
            controller: controller,
            query: query,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            onClear: onClear,
          ),
        ),
      ),
    );
  }
}
