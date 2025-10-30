import 'package:flutter/foundation.dart';
import '../models/order_record.dart';
import '../providers/cart_provider.dart';
import '../services/orders_db.dart';

class OrdersProvider extends ChangeNotifier {
  final _db = OrdersDb.instance;

  bool loading = false;
  List<OrderRecord> history = [];

  Future<void> load() async {
    loading = true;
    notifyListeners();

    final rows = await _db.fetchOrders();
    final List<OrderRecord> result = [];
    for (final r in rows) {
      final itemsRows = await _db.fetchItemsByOrder(r['id'] as String);
      result.add(
        OrderRecord(
          id: r['id'] as String,
          createdAt: DateTime.fromMillisecondsSinceEpoch(r['created_at'] as int),
          status: r['status'] as String,
          totalInIDR: r['total_idr'] as int,
          orderType: r['order_type'] as String?,
          deliveryAddress: r['delivery_address'] as String?,
          items: itemsRows
              .map((it) => OrderItemRecord(
                    name: it['name'] as String,
                    imageUrl: it['image_url'] as String?,
                    priceInIDR: it['price_idr'] as int,
                    quantity: it['quantity'] as int,
                  ))
              .toList(),
        ),
      );
    }
    history = result;
    loading = false;
    notifyListeners();
  }

  // Dipanggil saat checkout; tidak mengubah logika cart, hanya menyimpan ke DB
  Future<String> saveFromCart(CartProvider cart, {String status = 'Menunggu'}) async {
    final id = 'INV-${DateTime.now().millisecondsSinceEpoch}';
    await _db.insertOrder(
      id: id,
      createdAt: DateTime.now(),
      status: status,
      totalInIDR: cart.subtotalIDR,
      orderType: cart.orderType.name,          // gunakan properti yang sudah ada
      deliveryAddress: cart.deliveryAddress,   // gunakan properti yang sudah ada
      items: cart.items
          .map((e) => {
                'name': e.name,
                'image_url': e.imageUrl,
                'price_idr': e.priceInIDR,
                'quantity': e.quantity,
              })
          .toList(),
    );
    await load();
    return id;
  }

  Future<void> updateStatus(String orderId, String newStatus) async {
    await _db.updateStatus(orderId, newStatus);
    await load();
  }
}