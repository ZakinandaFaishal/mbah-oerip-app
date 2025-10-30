import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class OrdersDb {
  OrdersDb._();
  static final OrdersDb instance = OrdersDb._();

  static const _dbName = 'orders.db';
  static const _dbVersion = 1;

  static const tableOrders = 'orders';
  static const tableItems = 'order_items';

  Database? _db;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    Directory dir = await getApplicationDocumentsDirectory();
    final p = join(dir.path, _dbName);
    _db = await openDatabase(
      p,
      version: _dbVersion,
      onCreate: (db, v) async {
        await db.execute('''
          CREATE TABLE $tableOrders (
            id TEXT PRIMARY KEY,
            created_at INTEGER NOT NULL,
            status TEXT NOT NULL,
            total_idr INTEGER NOT NULL,
            order_type TEXT,
            delivery_address TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE $tableItems (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            order_id TEXT NOT NULL,
            name TEXT NOT NULL,
            image_url TEXT,
            price_idr INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            FOREIGN KEY(order_id) REFERENCES $tableOrders(id) ON DELETE CASCADE
          )
        ''');
      },
    );
    return _db!;
  }

  Future<void> insertOrder({
    required String id,
    required DateTime createdAt,
    required String status,
    required int totalInIDR,
    String? orderType,
    String? deliveryAddress,
    required List<Map<String, dynamic>> items,
  }) async {
    final db = await _open();
    await db.transaction((txn) async {
      await txn.insert(tableOrders, {
        'id': id,
        'created_at': createdAt.millisecondsSinceEpoch,
        'status': status,
        'total_idr': totalInIDR,
        'order_type': orderType,
        'delivery_address': deliveryAddress,
      });
      for (final it in items) {
        await txn.insert(tableItems, {
          'order_id': id,
          'name': it['name'],
          'image_url': it['image_url'],
          'price_idr': it['price_idr'],
          'quantity': it['quantity'],
        });
      }
    });
  }

  Future<List<Map<String, Object?>>> fetchOrders() async {
    final db = await _open();
    return db.query(tableOrders, orderBy: 'created_at DESC');
  }

  Future<List<Map<String, Object?>>> fetchItemsByOrder(String orderId) async {
    final db = await _open();
    return db.query(
      tableItems,
      where: 'order_id = ?',
      whereArgs: [orderId],
      orderBy: 'id ASC',
    );
  }

  Future<void> updateStatus(String orderId, String status) async {
    final db = await _open();
    await db.update(
      tableOrders,
      {'status': status},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  // Opsional untuk debugging
  Future<void> clearAll() async {
    final db = await _open();
    await db.delete(tableItems);
    await db.delete(tableOrders);
  }
}
