import 'package:flutter/material.dart';
import 'package:ingkung_mbah_oerip/screens/main_screen.dart'; // tambahkan ini
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/orders_provider.dart';
import '../theme.dart';
import 'cart_screen.dart';
import '../models/order_record.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with AutomaticKeepAliveClientMixin {
  final _idr = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final orders = context.watch<OrdersProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Pesanan'),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: AppTheme.primaryOrange,
            unselectedLabelColor: Colors.black54,
            indicatorColor: AppTheme.primaryOrange,
            tabs: [
              Tab(text: 'Belum Dibayar'),
              Tab(text: 'Riwayat'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _UnpaidTab(idr: _idr),
            orders.loading
                ? const Center(child: CircularProgressIndicator())
                : _HistoryTab(idr: _idr),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _UnpaidTab extends StatelessWidget {
  final NumberFormat idr;
  const _UnpaidTab({required this.idr});

  String _formatAmount(double amount, String currency) {
    final sym = CartProvider.currencySymbols[currency] ?? '';
    if (currency == 'IDR') return '$sym ${amount.toStringAsFixed(0)}';
    if (currency == 'JPY') return '$sym${amount.toStringAsFixed(0)}';
    return '$sym${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    // Tambah jarak dinamis: tinggi nav bar + setengah tinggi FAB + safe area + margin kecil
    final mq = MediaQuery.of(context);
    final bottomLift =
        kBottomNavigationBarHeight / 2 + mq.padding.bottom;
    final contentBottomSpacer = bottomLift + 60;

    if (cart.items.isEmpty) {
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
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => const MainScreen(initialIndex: 1), // buka tab Menu
                  ),
                );
              },
              label: const Text('Tambah Menu'),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryOrange.withOpacity(.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.primaryOrange.withOpacity(.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryOrange,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '${cart.items.length} item dalam keranjang • Tipe: ${cart.orderType.name}',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Item Pesanan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 10),
              ...cart.items.map((it) {
                final convertedPrice = cart.convertFromIDR(it.priceInIDR);
                final convertedTotal = convertedPrice * it.quantity;
                final priceText = _formatAmount(
                  convertedPrice,
                  cart.selectedCurrency,
                );
                final totalText = _formatAmount(
                  convertedTotal,
                  cart.selectedCurrency,
                );

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            it.imageUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 56,
                              height: 56,
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
                                it.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                priceText,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'x${it.quantity}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              totalText,
                              style: const TextStyle(
                                color: AppTheme.primaryOrange,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const SizedBox(height: 16),
              SizedBox(height: contentBottomSpacer), // spacer dinamis
            ],
          ),
        ),
        // Naikkan seluruh panel total dengan padding bawah eksternal
        Padding(
          padding: EdgeInsets.only(bottom: bottomLift),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Subtotal dipindah ke sini (di atas Mata Uang)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                idr.format(cart.subtotalIDR),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatAmount(
                                  cart.convertFromIDR(cart.subtotalIDR),
                                  cart.selectedCurrency,
                                ),
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Item',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(
                            '${cart.itemCount} barang',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Dropdown konversi mata uang
                Row(
                  children: [
                    const Text('Mata Uang:',
                        style:
                            TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButton<String>(
                          value: cart.selectedCurrency,
                          isExpanded: true,
                          underline: const SizedBox.shrink(),
                          items: CartProvider.currencyRates.keys.map((c) {
                            final sym = CartProvider.currencySymbols[c] ?? '';
                            return DropdownMenuItem(
                              value: c,
                              child: Text('$c ($sym)',
                                  style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (v) => v != null ? cart.setCurrency(v) : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total',
                        style:
                            TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          idr.format(cart.subtotalIDR),
                          style: const TextStyle(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatAmount(
                            cart.convertFromIDR(cart.subtotalIDR),
                            cart.selectedCurrency,
                          ),
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    // Edit di Keranjang (secondary)
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Edit di Keranjang'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CartScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          side: BorderSide(color: AppTheme.primaryOrange),
                          foregroundColor: AppTheme.primaryOrange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Checkout (primary)
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.payment_rounded),
                        label: const Text('Checkout'),
                        onPressed: () {
                          showDialog(
                            context: context,
                            useRootNavigator: false,
                            builder: (dialogContext) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              title: const Text('Konfirmasi Pesanan'),
                              content: Text(
                                'Tipe Pesanan: ${cart.orderType.name}\n'
                                'Total: ${idr.format(cart.subtotalIDR)}\n'
                                '(${_formatAmount(cart.convertFromIDR(cart.subtotalIDR), cart.selectedCurrency)})\n\n'
                                'Lanjutkan checkout?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    try {
                                      final ordersProv = context
                                          .read<OrdersProvider>();
                                      final cartProv = context
                                          .read<CartProvider>();
                                      final orderId = await ordersProv
                                          .saveFromCart(
                                            cartProv,
                                            status: 'Diproses',
                                          );
                                      cartProv.clear();
                                      if (context.mounted) {
                                        Navigator.of(dialogContext).pop();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor:
                                                Colors.green.shade600,
                                            content: Row(
                                              children: [
                                                const Icon(
                                                  Icons.check_circle,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    'Pesanan $orderId berhasil dibuat',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            margin: const EdgeInsets.fromLTRB(
                                              16,
                                              0,
                                              16,
                                              16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                        DefaultTabController.of(
                                          context,
                                        ).animateTo(1);
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        Navigator.of(dialogContext).pop();
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            backgroundColor:
                                                Colors.red.shade600,
                                            content: Row(
                                              children: [
                                                const Icon(
                                                  Icons.error_outline,
                                                  color: Colors.white,
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    'Gagal: ${e.toString()}',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            behavior: SnackBarBehavior.floating,
                                            margin: const EdgeInsets.fromLTRB(
                                              16,
                                              0,
                                              16,
                                              16,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryOrange,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Konfirmasi'),
                                ),
                              ],
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryOrange,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final NumberFormat idr;
  const _HistoryTab({required this.idr});

  String _formatAmount(double amount, String currency) {
    final sym = CartProvider.currencySymbols[currency] ?? '';
    if (currency == 'IDR') return '$sym ${amount.toStringAsFixed(0)}';
    if (currency == 'JPY') return '$sym${amount.toStringAsFixed(0)}';
    return '$sym${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
    final cart = context.watch<CartProvider>();
    final list = provider.history;

    if (list.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 60),
          Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'Belum ada riwayat pembelian',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: Text('Checkout dari keranjang untuk melihat riwayat'),
          ),
        ],
      );
    }

    return RefreshIndicator(
      onRefresh: provider.load,
      // Tambahkan padding bottom agar tidak tertutup navbar
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          kBottomNavigationBarHeight +
              MediaQuery.of(context).padding.bottom +
              24, // dinaikkan dari 100 -> sesuai navbar
        ),
        itemCount: list.length,
        itemBuilder: (_, i) {
          final o = list[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showDetail(context, o, cart),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryOrange.withOpacity(.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: AppTheme.primaryOrange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            o.id,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat(
                              'dd MMM yyyy, HH:mm',
                              'id_ID',
                            ).format(o.createdAt),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Chip(
                            label: Text(o.status),
                            backgroundColor: _statusColor(
                              o.status,
                            ).withOpacity(.12),
                            labelStyle: TextStyle(
                              color: _statusColor(o.status),
                              fontWeight: FontWeight.w600,
                            ),
                            side: BorderSide(
                              color: _statusColor(o.status).withOpacity(.4),
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          idr.format(o.totalInIDR),
                          style: const TextStyle(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDetail(BuildContext context, OrderRecord o, CartProvider cart) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (_, controller) {
            final convertedTotal = cart.convertFromIDR(o.totalInIDR);
            final convertedTotalText = _formatAmount(
              convertedTotal,
              cart.selectedCurrency,
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Pesanan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Text(o.id, style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Chip(
                      label: Text(o.status),
                      backgroundColor: _statusColor(o.status).withOpacity(.12),
                      labelStyle: TextStyle(
                        color: _statusColor(o.status),
                        fontWeight: FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: _statusColor(o.status).withOpacity(.4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat(
                        'dd MMM yyyy, HH:mm',
                        'id_ID',
                      ).format(o.createdAt),
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    controller: controller,
                    itemCount: o.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 8),
                    itemBuilder: (_, i) {
                      final it = o.items[i];
                      final convertedPrice = cart.convertFromIDR(it.priceInIDR);
                      final convertedItemTotal = convertedPrice * it.quantity;
                      final priceText = _formatAmount(
                        convertedPrice,
                        cart.selectedCurrency,
                      );
                      final itemTotalText = _formatAmount(
                        convertedItemTotal,
                        cart.selectedCurrency,
                      );

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            it.imageUrl ?? '',
                            width: 54,
                            height: 54,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 54,
                              height: 54,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                        title: Text(
                          it.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${it.quantity} x ${idr.format(it.priceInIDR)}',
                            ),
                            Text(
                              '(${it.quantity} x $priceText)',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              idr.format(it.priceInIDR * it.quantity),
                              style: const TextStyle(
                                color: AppTheme.primaryOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              itemTotalText,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      // Dropdown konversi mata uang
                      Row(
                        children: [
                          const Text(
                            'Mata Uang:',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: DropdownButton<String>(
                                value: cart.selectedCurrency,
                                isExpanded: true,
                                underline: const SizedBox.shrink(),
                                items: CartProvider.currencyRates.keys.map((c) {
                                  final sym =
                                      CartProvider.currencySymbols[c] ?? '';
                                  return DropdownMenuItem(
                                    value: c,
                                    child: Text('$c ($sym)'),
                                  );
                                }).toList(),
                                onChanged: (v) =>
                                    v != null ? cart.setCurrency(v) : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Total dengan konversi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                idr.format(o.totalInIDR),
                                style: const TextStyle(
                                  color: AppTheme.primaryOrange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                convertedTotalText,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Selesai':
        return Colors.green.shade600;
      case 'Diproses':
      case 'Menunggu':
        return Colors.orange.shade700;
      case 'Dibatalkan':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}
