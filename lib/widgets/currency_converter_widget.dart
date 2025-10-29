import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CurrencyConverterWidget extends StatefulWidget {
  final int priceInIDR;
  final Function(String) onCurrencyChanged;
  final String? initialCurrency;

  const CurrencyConverterWidget({
    super.key,
    required this.priceInIDR,
    required this.onCurrencyChanged,
    this.initialCurrency = 'IDR',
  });

  @override
  State<CurrencyConverterWidget> createState() => _CurrencyConverterWidgetState();
}

class _CurrencyConverterWidgetState extends State<CurrencyConverterWidget> {
  late String selectedCurrency;

  // Static conversion rates (1 IDR = ...)
  static const Map<String, double> conversionRates = {
    'IDR': 1.0,
    'USD': 0.000064,
    'EUR': 0.000059,
    'JPY': 0.0096,
    'HKD': 0.0005,
    'SGD': 0.000087,
    'AUD': 0.00009,
    'GBP': 0.000051,
    'SAR': 0.00024,
  };

  static const Map<String, String> currencySymbols = {
    'IDR': 'Rp',
    'USD': '\$',
    'EUR': '€',
    'JPY': '¥',
    'HKD': 'HK\$',
    'SGD': 'S\$',
    'AUD': 'A\$',
    'GBP': '£',
    'SAR': 'SR',
  };

  @override
  void initState() {
    super.initState();
    selectedCurrency = widget.initialCurrency ?? 'IDR';
  }

  double _convertPrice(String currency) {
    return widget.priceInIDR * (conversionRates[currency] ?? 1.0);
  }

  String _formatPrice(double price, String currency) {
    if (currency == 'IDR') {
      return NumberFormat.currency(
        locale: 'id_ID',
        symbol: currencySymbols[currency],
        decimalDigits: 0,
      ).format(price);
    } else if (currency == 'JPY') {
      return '${currencySymbols[currency]}${price.toStringAsFixed(0)}';
    } else {
      return '${currencySymbols[currency]}${price.toStringAsFixed(2)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: selectedCurrency,
            isExpanded: true,
            underline: const SizedBox(),
            items: conversionRates.keys.map((currency) {
              return DropdownMenuItem(
                value: currency,
                child: Text(
                  currency,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => selectedCurrency = value);
                widget.onCurrencyChanged(value);
              }
            },
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Harga:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              Text(
                _formatPrice(_convertPrice(selectedCurrency), selectedCurrency),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}