import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order_record.dart';
import '../../providers/orders_provider.dart';
import '../../theme.dart';
import 'order_detail_sheet.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  NumberFormat get _idr =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

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
        padding: EdgeInsets.fromLTRB(
          16,
          12,
          16,
          kBottomNavigationBarHeight +
              MediaQuery.of(context).padding.bottom +
              24,
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
                          _idr.format(o.totalInIDR),
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
      builder: (_) => OrderDetailSheet(order: o),
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
