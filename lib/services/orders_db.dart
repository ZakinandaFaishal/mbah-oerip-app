import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class OrdersDb {
  OrdersDb._();
  static final OrdersDb instance = OrdersDb._();

  static const tableOrders = 'orders';
  static const tableItems = 'order_items';
  SupabaseClient get _client => Supabase.instance.client;
  String? get _uid => _client.auth.currentUser?.id;

  Future<void> insertOrder({
    required String id,
    required DateTime
    createdAt, // (tidak lagi dipakai langsung, tapi tetap diterima untuk konsistensi)
    required String status,
    required int totalInIDR,
    String? orderType,
    String? deliveryAddress,
    required List<Map<String, dynamic>> items,
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw Exception('User belum login / session null');
    }

    try {
      // Insert order tanpa user_id (gunakan DEFAULT auth.uid()) dan tanpa created_at (default now())
      await _client.from(tableOrders).insert({
        'id': id,
        'user_id': uid, // penting: pastikan lolos RLS & FK
        'status': status,
        'total_idr': totalInIDR,
        'order_type': orderType,
        'delivery_address': deliveryAddress,
      });

      if (items.isNotEmpty) {
        final rows = items.map(
          (it) => {
            'order_id': id,
            'name': it['name'],
            'image_url': it['image_url'],
            'price_idr': it['price_idr'],
            'quantity': it['quantity'],
          },
        );
        await _client.from(tableItems).insert(rows.toList());
      }
    } on PostgrestException catch (e) {
      // Tambah log detail user id & error
      // ignore: avoid_print
      print(
        '[OrdersDb] Insert gagal user_id=$uid code=${e.code} msg=${e.message}',
      );
      rethrow;
    }
  }

  Future<List<Map<String, Object?>>> fetchOrders() async {
    final uid = _uid;
    if (uid == null) return [];
    final data = await _client
        .from(tableOrders)
        .select()
        .eq('user_id', uid)
        .order('created_at', ascending: false);

    // Normalisasi bentuk data seperti sebelumnya
    return (data as List<dynamic>)
        .map<Map<String, Object?>>(
          (r) => {
            'id': r['id'] as String,
            'created_at': r['created_at'] as String,
            'status': r['status'] as String,
            'total_idr': r['total_idr'] as int,
            'order_type': r['order_type'],
            'delivery_address': r['delivery_address'],
          },
        )
        .toList();
  }

  Future<List<Map<String, Object?>>> fetchItemsByOrder(String orderId) async {
    final data = await _client
        .from(tableItems)
        .select()
        .eq('order_id', orderId)
        .order('id');
    return (data as List<dynamic>)
        .map<Map<String, Object?>>(
          (it) => {
            'name': it['name'],
            'image_url': it['image_url'],
            'price_idr': it['price_idr'],
            'quantity': it['quantity'],
          },
        )
        .toList();
  }

  Future<void> updateStatus(String orderId, String status) async {
    final uid = _uid;
    if (uid == null) return;
    await _client.from(tableOrders).update({'status': status}).match({
      'id': orderId,
      'user_id': uid,
    });
  }

  // Opsional untuk debugging: hapus semua (user saat ini)
  Future<void> clearAll() async {
    final uid = _uid;
    if (uid == null) return;
    final idsData = await _client
        .from(tableOrders)
        .select('id')
        .eq('user_id', uid);
    final ids = (idsData as List<dynamic>)
        .map((e) => e['id'] as String)
        .toList();
    if (ids.isEmpty) return; // tidak ada order untuk user ini

    // Hapus detail terlebih dahulu tanpa method in_/inFilter (kompatibel lintas versi):
    final orFilter = ids.map((id) => 'order_id.eq.$id').join(',');
    await _client.from(tableItems).delete().or(orFilter);
    // Hapus orders milik user (semua order milik user ini)
    await _client.from(tableOrders).delete().eq('user_id', uid);
  }
}
