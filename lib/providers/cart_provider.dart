import 'package:flutter/foundation.dart';

class CartItem {
  final int id;
  final String name;
  final String imageUrl;
  final int priceInIDR;
  int quantity;

  CartItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.priceInIDR,
    this.quantity = 1,
  });
}

enum OrderType { dineIn, delivery, pickup }

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);

  // State pemesanan
  OrderType _orderType = OrderType.dineIn;
  OrderType get orderType => _orderType;

  String? _deliveryAddress;
  String? get deliveryAddress => _deliveryAddress;

  // Mata uang
  String _selectedCurrency = 'IDR';
  String get selectedCurrency => _selectedCurrency;

  // Kurs (1 IDR = rate)
  static const Map<String, double> currencyRates = {
    'IDR': 1.0,
    'USD': 0.000064,
    'EUR': 0.000059,
    'JPY': 0.0096,
    'HKD': 0.00050,
    'SGD': 0.000087,
    'AUD': 0.000090,
    'GBP': 0.000051,
    'SAR': 0.000240,
  };

  static const Map<String, String> currencySymbols = {
    'IDR': 'Rp',
    'USD': r'$',
    'EUR': '€',
    'JPY': '¥',
    'HKD': r'HK$',
    'SGD': r'S$',
    'AUD': r'A$',
    'GBP': '£',
    'SAR': 'SR',
  };

  // Add/update item
  void addItem({
    required int id,
    required String name,
    required String imageUrl,
    required int priceInIDR,
    int quantity = 1,
  }) {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx != -1) {
      _items[idx].quantity += quantity;
    } else {
      _items.add(
        CartItem(
          id: id,
          name: name,
          imageUrl: imageUrl,
          priceInIDR: priceInIDR,
          quantity: quantity,
        ),
      );
    }
    notifyListeners();
  }

  void removeItem(int id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void setQuantity(int id, int qty) {
    final i = _items.indexWhere((e) => e.id == id);
    if (i != -1 && qty > 0) {
      _items[i].quantity = qty;
      notifyListeners();
    }
  }

  // Totals
  int get itemCount => _items.fold(0, (s, e) => s + e.quantity);
  int get subtotalIDR =>
      _items.fold(0, (s, e) => s + (e.priceInIDR * e.quantity));

  // Tambahkan alias agar kompatibel dengan kode lama
  int get cartCount => itemCount;

  double convertFromIDR(int amountIDR, [String? currency]) {
    final c = currency ?? _selectedCurrency;
    return amountIDR * (currencyRates[c] ?? 1.0);
  }

  // Order type, address, currency
  void setOrderType(OrderType type) {
    _orderType = type;
    notifyListeners();
  }

  void setDeliveryAddress(String? address) {
    _deliveryAddress = address;
    notifyListeners();
  }

  void setCurrency(String currency) {
    if (currencyRates.keys.contains(currency)) {
      _selectedCurrency = currency;
      notifyListeners();
    }
  }
}
