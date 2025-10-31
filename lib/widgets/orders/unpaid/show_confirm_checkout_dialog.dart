import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/orders_provider.dart';
import '../../../services/notification_service.dart';
import '../../../theme.dart';
import 'format.dart';

Future<void> showConfirmCheckoutDialog(BuildContext context) async {
  final cart = context.read<CartProvider>();
  await showDialog(
    context: context,
    useRootNavigator: false,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      title: const Text('Konfirmasi Pesanan'),
      content: Text(
        'Tipe Pesanan: ${cart.orderType.name}\n'
        'Total: ${idr().format(cart.subtotalIDR)}\n'
        '(${formatMoney(cart.convertFromIDR(cart.subtotalIDR), cart.selectedCurrency)})\n\n'
        'Lanjutkan checkout?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              final ordersProv = context.read<OrdersProvider>();
              final cartProv = context.read<CartProvider>();
              final totalIdr = cartProv.subtotalIDR;
              final orderId = await ordersProv.saveFromCart(
                cartProv,
                status: 'Diproses',
              );

              await NotificationService.instance.showOrderSuccess(
                orderId: orderId,
                totalInIDR: totalIdr,
              );

              cartProv.clear();
              if (context.mounted) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.green.shade600,
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.white),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Pesanan berhasil dibuat',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
                DefaultTabController.of(context).animateTo(1);
              }
            } catch (e) {
              if (context.mounted) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red.shade600,
                    content: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Gagal: $e',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryOrange,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Konfirmasi'),
        ),
      ],
    ),
  );
}
