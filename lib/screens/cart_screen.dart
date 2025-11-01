import 'package:flutter/material.dart';
import 'package:ingkung_mbah_oerip/screens/login_screen.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../providers/auth_provider.dart';
import '../services/location_services.dart';
import '../services/notification_service.dart';

import '../widgets/cart/order_type_selector.dart';
import '../widgets/cart/address_section.dart';
import '../widgets/cart/currency_selector.dart';
import '../widgets/cart/cart_item_card.dart';
import '../widgets/cart/bottom_checkout_bar.dart';
import '../widgets/cart/empty_cart.dart';
import '../utils/snackbar_utils.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _loc = LocationService();
  final _addrCtrl = TextEditingController();
  bool _locLoading = false;

  @override
  void dispose() {
    _addrCtrl.dispose();
    super.dispose();
  }

  String _formatAmount(double amount, String currency) {
    final sym = CartProvider.currencySymbols[currency] ?? '';
    if (currency == 'IDR') {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: '$sym ',
        decimalDigits: 0,
      ).format(amount);
    }
    if (currency == 'JPY') {
      return '$sym${amount.toStringAsFixed(0)}';
    }
    return '$sym${amount.toStringAsFixed(2)}';
  }

  Future<void> _detectAddress() async {
    setState(() => _locLoading = true);
    try {
      final loc = await _loc.getCurrentLocation(context);
      if (loc != null && mounted) {
        final addr = await _loc.getAddressFromCoordinates(
          loc.latitude ?? 0,
          loc.longitude ?? 0,
        );
        context.read<CartProvider>().setDeliveryAddress(addr);
        _addrCtrl.text = addr ?? '';
        if (mounted) {
          showModernSnackBar(
            context,
            message: 'Alamat terdeteksi',
            icon: Icons.location_on,
            color: Colors.green.shade600,
          );
        }
      }
    } finally {
      if (mounted) setState(() => _locLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final currency = cart.selectedCurrency;

    return Scaffold(
      appBar: AppBar(title: const Text('Keranjang'), centerTitle: true),
      body: cart.items.isEmpty
          ? const EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      OrderTypeSelector(
                        selected: cart.orderType,
                        onChanged: cart.setOrderType,
                      ),
                      if (cart.orderType == OrderType.delivery) ...[
                        const SizedBox(height: 16),
                        AddressSection(
                          controller: _addrCtrl
                            ..text = cart.deliveryAddress ?? '',
                          loading: _locLoading,
                          onDetect: _detectAddress,
                          onChanged: (v) => context
                              .read<CartProvider>()
                              .setDeliveryAddress(v),
                        ),
                      ],
                      const SizedBox(height: 16),
                      CurrencySelector(
                        value: currency,
                        onChanged: (c) => cart.setCurrency(c),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Item Pesanan',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...cart.items.map((it) {
                        final itemPrice = cart.convertFromIDR(it.priceInIDR);
                        final itemTotal = cart.convertFromIDR(
                          it.priceInIDR * it.quantity,
                        );
                        return CartItemCard(
                          name: it.name,
                          imageUrl: it.imageUrl,
                          priceText: _formatAmount(itemPrice, currency),
                          totalText: _formatAmount(itemTotal, currency),
                          quantity: it.quantity,
                          onInc: () => cart.setQuantity(it.id, it.quantity + 1),
                          onDec: () => cart.setQuantity(it.id, it.quantity - 1),
                          onRemove: () => cart.removeItem(it.id),
                        );
                      }),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
                BottomCheckoutBar(
                  totalText: _formatAmount(
                    cart.convertFromIDR(cart.subtotalIDR),
                    currency,
                  ),
                  onCheckout: () {
                    // Validasi alamat untuk delivery
                    if (cart.orderType == OrderType.delivery &&
                        (cart.deliveryAddress == null ||
                            cart.deliveryAddress!.trim().isEmpty)) {
                      showModernSnackBar(
                        context,
                        message: 'Isi alamat untuk delivery',
                        icon: Icons.error_outline,
                        color: Colors.red,
                      );
                      return;
                    }

                    final parentContext = context;

                    showDialog(
                      context: context,
                      useRootNavigator: false,
                      builder: (dialogContext) => AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        title: const Text('Konfirmasi Pesanan'),
                        content: Text(
                          'Tipe: ${cart.orderType.name}\n'
                          'Total: ${_formatAmount(cart.convertFromIDR(cart.subtotalIDR), currency)}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              final auth = context.read<AuthProvider>();
                              // Require login to perform checkout
                              if (!auth.isLoggedIn) {
                                // Show dialog prompting user to login or cancel
                                if (context.mounted) {
                                  showDialog(
                                    context: context,
                                    builder: (dCtx) => AlertDialog(
                                      title: const Text('Perlu Login'),
                                      content: const Text(
                                        'Anda harus login untuk melakukan checkout. Silakan login atau daftar terlebih dahulu.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(dCtx).pop(),
                                          child: const Text('Batal'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(dCtx).pop();
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const LoginScreen(),
                                              ),
                                            );
                                          },
                                          child: const Text('Login'),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                                return;
                              }

                              try {
                                final ordersProv = parentContext
                                    .read<OrdersProvider>();
                                final cartProv = parentContext
                                    .read<CartProvider>();
                                final totalIdr = cartProv
                                    .subtotalIDR; // simpan sebelum clear

                                final orderId = await ordersProv.saveFromCart(
                                  cartProv,
                                  status: 'Diproses',
                                );

                                // Tampilkan notifikasi
                                await NotificationService.instance
                                    .showOrderSuccess(
                                      orderId: orderId,
                                      totalInIDR: totalIdr,
                                    );

                                cartProv.clear();

                                if (parentContext.mounted) {
                                  Navigator.of(
                                    dialogContext,
                                  ).pop(); // Tutup dialog
                                  Navigator.of(
                                    parentContext,
                                  ).pop(); // Tutup CartScreen
                                  showModernSnackBar(
                                    parentContext,
                                    message: 'Pesanan $orderId berhasil dibuat',
                                    icon: Icons.check_circle,
                                    color: Colors.green.shade600,
                                  );
                                }
                              } catch (e) {
                                // FIX: Tampilkan pesan error yang lebih detail
                                if (parentContext.mounted) {
                                  Navigator.of(
                                    dialogContext,
                                  ).pop(); // Tutup dialog dulu
                                  showModernSnackBar(
                                    parentContext,
                                    message:
                                        'Gagal menyimpan pesanan: ${e.toString()}',
                                    icon: Icons.error_outline,
                                    color: Colors.red,
                                  );
                                }
                              }
                            },
                            child: const Text('Pesan'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
