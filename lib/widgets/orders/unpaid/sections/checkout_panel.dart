import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../providers/cart_provider.dart';
import '../../../../theme.dart';

class CheckoutPanel extends StatelessWidget {
  final CartProvider cart;
  final NumberFormat idr;
  final String Function(double amount, String currency) formatMoney;
  final VoidCallback onEditCart;
  final VoidCallback onCheckout;

  const CheckoutPanel({
    super.key,
    required this.cart,
    required this.idr,
    required this.formatMoney,
    required this.onEditCart,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          idr.format(cart.subtotalIDR),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          formatMoney(
                            cart.convertFromIDR(cart.subtotalIDR),
                            cart.selectedCurrency,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Item',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '${cart.itemCount} barang',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Mata Uang:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
                      final sym = CartProvider.currencySymbols[c] ?? '';
                      return DropdownMenuItem(
                        value: c,
                        child: Text(
                          '$c ($sym)',
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (v) => v != null ? cart.setCurrency(v) : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    idr.format(cart.subtotalIDR),
                    style: const TextStyle(
                      color: AppTheme.primaryOrange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    formatMoney(
                      cart.convertFromIDR(cart.subtotalIDR),
                      cart.selectedCurrency,
                    ),
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
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit di Keranjang'),
                  onPressed: onEditCart,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    side: const BorderSide(color: AppTheme.primaryOrange),
                    foregroundColor: AppTheme.primaryOrange,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.payment_rounded,
                    color: AppTheme.goldLight,
                  ),
                  label: const Text('Checkout'),
                  onPressed: onCheckout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
