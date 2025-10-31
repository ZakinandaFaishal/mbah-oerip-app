import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../theme.dart';
import '../../screens/cart_screen.dart';
import '../../screens/main_screen.dart';
import 'unpaid/format.dart';
import 'unpaid/sections/cart_empty_state.dart';
import 'unpaid/sections/info_banner.dart';
import 'unpaid/sections/cart_items_list.dart';
import 'unpaid/sections/checkout_panel.dart';
import 'unpaid/show_confirm_checkout_dialog.dart';

class UnpaidTab extends StatelessWidget {
  const UnpaidTab({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final mq = MediaQuery.of(context);
    final bottomLift = kBottomNavigationBarHeight / 2 + mq.padding.bottom;
    final contentBottomSpacer = bottomLift + 60;

    if (cart.items.isEmpty) {
      return CartEmptyState(
        onAddMenu: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => const MainScreen(initialIndex: 1),
            ),
          );
        },
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            children: [
              InfoBanner(
                text:
                    '${cart.items.length} item dalam keranjang • Tipe: ${cart.orderType.name}',
                color: AppTheme.primaryOrange,
              ),
              const SizedBox(height: 16),
              const Text(
                'Item Pesanan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 10),
              CartItemsList(cart: cart, formatMoney: formatMoney),
              const SizedBox(height: 16),
              SizedBox(height: contentBottomSpacer),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.only(bottom: bottomLift),
          child: CheckoutPanel(
            cart: cart,
            idr: idr(),
            formatMoney: formatMoney,
            onEditCart: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
            onCheckout: () => showConfirmCheckoutDialog(context),
          ),
        ),
      ],
    );
  }
}
