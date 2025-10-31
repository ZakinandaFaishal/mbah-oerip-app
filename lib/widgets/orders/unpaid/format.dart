import 'package:intl/intl.dart';
import '../../../providers/cart_provider.dart';

NumberFormat idr() =>
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

String formatMoney(double amount, String currency) {
  final sym = CartProvider.currencySymbols[currency] ?? '';
  if (currency == 'IDR' || currency == 'JPY') {
    return '$sym${currency == "IDR" ? ' ' : ''}${amount.toStringAsFixed(0)}';
  }
  return '$sym${amount.toStringAsFixed(2)}';
}
