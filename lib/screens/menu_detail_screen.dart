import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/menu_item.dart';
import '../theme.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

// widgets
import '../widgets/menu_detail/detail_header_image.dart';
import '../widgets/menu_detail/detail_info_section.dart';
import '../widgets/menu_detail/price_currency_section.dart';
import '../widgets/menu_detail/qty_add_to_cart_bar.dart';
import '../utils/snackbar_utils.dart';

class MenuDetailScreen extends StatefulWidget {
  final MenuItem item;
  final String categoryName;

  const MenuDetailScreen({
    super.key,
    required this.item,
    required this.categoryName,
  });

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  int _qty = 1;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final idr = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text(
          widget.item.name,
          style: const TextStyle(color: AppTheme.primaryOrange),
        ),
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppTheme.primaryOrange),
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
              if (cart.cartCount > 0)
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
                      '${cart.cartCount}',
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
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DetailHeaderImage(imageUrl: widget.item.imageUrl),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DetailInfoSection(
                    categoryName: widget.categoryName,
                    title: widget.item.name,
                    description: widget.item.description,
                    idrPriceText: idr.format(widget.item.price),
                  ),
                  const SizedBox(height: 8),
                  PriceCurrencySection(priceInIDR: widget.item.price),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: QtyAddToCartBar(
            qty: _qty,
            onDec: _qty > 1 ? () => setState(() => _qty--) : null,
            onInc: () => setState(() => _qty++),
            onAdd: () {
              context.read<CartProvider>().addItem(
                id: widget.item.id,
                name: widget.item.name,
                imageUrl: widget.item.imageUrl,
                priceInIDR: widget.item.price,
                quantity: _qty,
              );
              showModernSnackBar(
                context,
                message: 'Ditambahkan ke keranjang',
                icon: Icons.add_shopping_cart,
                color: Colors.green.shade600,
                duration: const Duration(milliseconds: 900),
                actionLabel: 'Buka',
                onAction: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
