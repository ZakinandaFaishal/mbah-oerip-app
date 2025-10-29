import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final _idr = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _filter = 'Semua';
  bool _loading = true;
  List<OrderHistory> _all = [];
  List<OrderHistory> _filtered = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    // TODO: Ganti dengan pemanggilan API nyata bila tersedia
    await Future.delayed(const Duration(milliseconds: 600));
    final demo = _generateDemoOrders();
    setState(() {
      _all = demo;
      _applyFilter();
      _loading = false;
    });
  }

  void _applyFilter() {
    if (_filter == 'Semua') {
      _filtered = List.of(_all);
    } else {
      _filtered = _all.where((o) => o.status == _filter).toList();
    }
  }

  void _setFilter(String f) {
    setState(() {
      _filter = f;
      _applyFilter();
    });
  }

  String _formatDate(DateTime d) =>
      DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(d);

  void _showDetail(OrderHistory order) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Pesanan',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(order.id, style: TextStyle(color: Colors.grey.shade700)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Chip(
                        label: Text(order.status),
                        backgroundColor: _statusColor(
                          order.status,
                        ).withOpacity(.12),
                        labelStyle: TextStyle(
                          color: _statusColor(order.status),
                          fontWeight: FontWeight.w600,
                        ),
                        side: BorderSide(
                          color: _statusColor(order.status).withOpacity(.4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(order.createdAt),
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      controller: controller,
                      itemBuilder: (_, i) {
                        final it = order.items[i];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              it.imageUrl,
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
                            '${it.quantity} x ${_idr.format(it.priceInIDR)}',
                          ),
                          trailing: Text(
                            _idr.format(it.priceInIDR * it.quantity),
                            style: const TextStyle(
                              color: AppTheme.primaryOrange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const Divider(height: 8),
                      itemCount: order.items.length,
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
                        _idr.format(order.totalInIDR),
                        style: const TextStyle(
                          color: AppTheme.primaryOrange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.receipt_long),
                      label: const Text('Unduh Struk'),
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Fitur unduh struk belum tersedia'),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'Selesai':
        return Colors.green.shade600;
      case 'Diproses':
        return Colors.orange.shade700;
      case 'Dibatalkan':
        return Colors.red.shade600;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = const ['Semua', 'Selesai', 'Diproses', 'Dibatalkan'];

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Pesanan'), centerTitle: true),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _filtered.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 100),
                  Icon(
                    Icons.receipt_long,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Belum ada riwayat pesanan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Center(child: Text('Pesanan Anda akan muncul di sini')),
                ],
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  // Filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: filters.map((f) {
                        final selected = _filter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(f),
                            selected: selected,
                            onSelected: (_) => _setFilter(f),
                            selectedColor: AppTheme.primaryOrange.withOpacity(
                              .15,
                            ),
                            labelStyle: TextStyle(
                              color: selected
                                  ? AppTheme.primaryOrange
                                  : Colors.black87,
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            side: BorderSide(
                              color: selected
                                  ? AppTheme.primaryOrange
                                  : Colors.grey.shade300,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // List orders
                  ..._filtered.map((o) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showDetail(o),
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
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      _formatDate(o.createdAt),
                                      style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 8,
                                      children: [
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
                                            color: _statusColor(
                                              o.status,
                                            ).withOpacity(.4),
                                          ),
                                          visualDensity: VisualDensity.compact,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _idr.format(o.totalInIDR),
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
                  }),
                ],
              ),
      ),
    );
  }

  // Demo data
  List<OrderHistory> _generateDemoOrders() {
    return [
      OrderHistory(
        id: 'INV-202510-0001',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        status: 'Selesai',
        items: [
          OrderItem(
            name: 'Ayam Ingkung Spesial',
            imageUrl:
                'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=800',
            priceInIDR: 56000,
            quantity: 1,
          ),
          OrderItem(
            name: 'Es Teh Manis',
            imageUrl:
                'https://images.unsplash.com/photo-1541976076758-347942db1970?w=800',
            priceInIDR: 8000,
            quantity: 2,
          ),
        ],
      ),
      OrderHistory(
        id: 'INV-202510-0002',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 1)),
        status: 'Diproses',
        items: [
          OrderItem(
            name: 'Sate Ayam',
            imageUrl:
                'https://images.unsplash.com/photo-1553621042-f6e147245754?w=800',
            priceInIDR: 24000,
            quantity: 2,
          ),
        ],
      ),
      OrderHistory(
        id: 'INV-202510-0003',
        createdAt: DateTime.now().subtract(const Duration(days: 3, hours: 5)),
        status: 'Dibatalkan',
        items: [
          OrderItem(
            name: 'Nasi Liwet',
            imageUrl:
                'https://images.unsplash.com/photo-1604908554037-7c04c2200ef1?w=800',
            priceInIDR: 18000,
            quantity: 1,
          ),
        ],
      ),
    ];
  }
}

class OrderHistory {
  final String id;
  final DateTime createdAt;
  final String status; // 'Selesai', 'Diproses', 'Dibatalkan'
  final List<OrderItem> items;

  OrderHistory({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.items,
  });

  int get totalInIDR => items.fold(0, (s, e) => s + e.priceInIDR * e.quantity);
}

class OrderItem {
  final String name;
  final String imageUrl;
  final int priceInIDR;
  final int quantity;

  OrderItem({
    required this.name,
    required this.imageUrl,
    required this.priceInIDR,
    required this.quantity,
  });
}
