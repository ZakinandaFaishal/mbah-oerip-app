import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    // Kosong → ajak buka keranjang
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
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 6),
          const Center(child: Text('Tambahkan menu untuk melanjutkan')),
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              child: const Text('Buka Keranjang'),
            ),
          ),
        ],
      );
    }

    // Tampilkan isi cart + tombol Checkout
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ...cart.items.map(
          (it) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                it.imageUrl,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 48,
                  height: 48,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image_not_supported),
                ),
              ),
            ),
            title: Text(it.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text('x${it.quantity} • ${idr.format(it.priceInIDR)}'),
            trailing: Text(
              idr.format(it.priceInIDR * it.quantity),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryOrange,
              ),
            ),
          ),
        ),
        const Divider(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Subtotal',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              idr.format(cart.subtotalIDR),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () async {
            final orders = context.read<OrdersProvider>();
            final id = await orders.saveFromCart(
              cart,
              status: 'Diproses',
            ); // simpan ke SQLite
            cart.clear(); // tetap sama: kosongkan cart setelah checkout
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Pesanan $id dibuat')));
              DefaultTabController.of(
                context,
              ).animateTo(1); // pindah ke Riwayat
            }
          },
          icon: const Icon(Icons.payment),
          label: const Text('Checkout'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryOrange,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          },
          child: const Text('Edit di Keranjang'),
        ),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final NumberFormat idr;
  const _HistoryTab({required this.idr});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrdersProvider>();
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
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
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
              onTap: () => _showDetail(context, o),
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
                        const Icon(Icons.chevron_right),
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

  void _showDetail(BuildContext context, OrderRecord o) {
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
                        subtitle: Text(
                          '${it.quantity} x ${idr.format(it.priceInIDR)}',
                        ),
                        trailing: Text(
                          idr.format(it.priceInIDR * it.quantity),
                          style: const TextStyle(
                            color: AppTheme.primaryOrange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      'Total',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Text(
                      idr.format(o.totalInIDR),
                      style: const TextStyle(
                        color: AppTheme.primaryOrange,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
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
