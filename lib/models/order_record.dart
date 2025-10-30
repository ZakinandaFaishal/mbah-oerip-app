class OrderRecord {
  final String id;
  final DateTime createdAt;
  final String status; // Menunggu/Diproses/Selesai/Dibatalkan
  final int totalInIDR;
  final String? orderType;
  final String? deliveryAddress; 
  final List<OrderItemRecord> items;

  const OrderRecord({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.totalInIDR,
    this.orderType,
    this.deliveryAddress, 
    required this.items,
  });
}

class OrderItemRecord {
  final String name;
  final String? imageUrl;
  final int priceInIDR;
  final int quantity;

  const OrderItemRecord({
    required this.name,
    required this.imageUrl,
    required this.priceInIDR,
    required this.quantity,
  });
}
