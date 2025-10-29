import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../services/location_services.dart';
import '../theme.dart';

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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Alamat terdeteksi')));
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
          ? _EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _OrderTypeSelector(
                        selected: cart.orderType,
                        onChanged: cart.setOrderType,
                      ),
                      if (cart.orderType == OrderType.delivery) ...[
                        const SizedBox(height: 16),
                        _AddressSection(
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
                      _CurrencySelector(
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
                        return _CartItemCard(
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
                _BottomCheckoutBar(
                  totalText: _formatAmount(
                    cart.convertFromIDR(cart.subtotalIDR),
                    currency,
                  ),
                  onCheckout: () {
                    if (cart.orderType == OrderType.delivery &&
                        (cart.deliveryAddress == null ||
                            cart.deliveryAddress!.trim().isEmpty)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Isi alamat untuk delivery'),
                        ),
                      );
                      return;
                    }
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
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
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Batal'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              cart.clear();
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Pesanan dibuat')),
                              );
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

class _OrderTypeSelector extends StatelessWidget {
  final OrderType selected;
  final ValueChanged<OrderType> onChanged;
  const _OrderTypeSelector({required this.selected, required this.onChanged});

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

class _AddressSection extends StatelessWidget {
  final TextEditingController controller;
  final bool loading;
  final VoidCallback onDetect;
  final ValueChanged<String> onChanged;
  const _AddressSection({
    required this.controller,
    required this.loading,
    required this.onDetect,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Alamat Pengiriman',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 3,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Masukkan alamat pengiriman',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: loading ? null : onDetect,
            icon: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : const Icon(Icons.my_location),
            label: const Text('Deteksi Lokasi Otomatis'),
          ),
        ),
      ],
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const _CurrencySelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pilih Mata Uang',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            items: CartProvider.currencyRates.keys.map((c) {
              final sym = CartProvider.currencySymbols[c] ?? '';
              return DropdownMenuItem(value: c, child: Text('$c ($sym)'));
            }).toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String priceText;
  final String totalText;
  final int quantity;
  final VoidCallback onInc;
  final VoidCallback onDec;
  final VoidCallback onRemove;

  const _CartItemCard({
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

class _BottomCheckoutBar extends StatelessWidget {
  final String totalText;
  final VoidCallback onCheckout;
  const _BottomCheckoutBar({required this.totalText, required this.onCheckout});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey.shade200)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total', style: TextStyle(color: Colors.grey)),
                  Text(
                    totalText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryOrange,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: onCheckout,
                child: const Text(
                  'Checkout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 84,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              'Keranjang kosong',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text('Tambahkan menu favorit Anda'),
          ],
        ),
      ),
    );
  }
}
