import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order_record.dart';
import '../../providers/cart_provider.dart';
import '../../theme.dart';

class OrderDetailSheet extends StatelessWidget {
  final OrderRecord order;
  const OrderDetailSheet({super.key, required this.order});

  NumberFormat get _idr =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  String _fmt(double amount, String currency) {
    final sym = CartProvider.currencySymbols[currency] ?? '';
    if (currency == 'IDR') return '$sym ${amount.toStringAsFixed(0)}';
    if (currency == 'JPY') return '$sym${amount.toStringAsFixed(0)}';
    return '$sym${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = ScrollController();
    final cart = context.watch<CartProvider>();
    final convertedTotal = cart.convertFromIDR(order.totalInIDR);
    final convertedTotalText = _fmt(convertedTotal, cart.selectedCurrency);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (_, __) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detail Pesanan',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                    DateFormat(
                      'dd MMM yyyy, HH:mm',
                      'id_ID',
                    ).format(order.createdAt),
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  controller: controller,
                  itemCount: order.items.length,
                  separatorBuilder: (_, __) => const Divider(height: 8),
                  itemBuilder: (_, i) {
                    final it = order.items[i];
                    final convertedPrice = cart.convertFromIDR(it.priceInIDR);
                    final convertedItemTotal = convertedPrice * it.quantity;
                    final priceText = _fmt(
                      convertedPrice,
                      cart.selectedCurrency,
                    );
                    final itemTotalText = _fmt(
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
                            '${it.quantity} x ${_idr.format(it.priceInIDR)}',
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
                            _idr.format(it.priceInIDR * it.quantity),
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
                    Row(
                      children: [
                        const Text(
                          'Mata Uang:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
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
                              _idr.format(order.totalInIDR),
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
