import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class CurrencyConverterWidget extends StatefulWidget {
  const CurrencyConverterWidget({super.key});

  @override
  _CurrencyConverterWidgetState createState() => _CurrencyConverterWidgetState();
}

class _CurrencyConverterWidgetState extends State<CurrencyConverterWidget> {
  final _idrController = TextEditingController();
  Map<String, double> _rates = {};
  bool _isLoading = true;
  String _error = '';

  // GANTI DENGAN API KEY ANDA
  final String _apiKey = "YOUR_API_KEY";

  @override
  void initState() {
    super.initState();
    _fetchRates();
  }

  Future<void> _fetchRates() async {
    final url = "https://v6.exchangerate-api.com/v6/$_apiKey/latest/IDR";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['result'] == 'success') {
          setState(() {
            _rates['USD'] = data['conversion_rates']['USD'];
            _rates['EUR'] = data['conversion_rates']['EUR'];
            _rates['SGD'] = data['conversion_rates']['SGD'];
            _isLoading = false;
          });
        }
      } else {
        throw Exception('Gagal memuat kurs');
      }
    } catch (e) {
      setState(() {
        _error = 'Tidak dapat mengambil data kurs. Cek koneksi atau API Key.';
        _isLoading = false;
      });
    }
  }

  double _convert(double amount, String currency) {
    if (_rates.containsKey(currency)) {
      return amount * _rates[currency]!;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Konversi Mata Uang", style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextField(
              controller: _idrController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah dalam IDR (Rupiah)',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {}); // Trigger rebuild untuk update hasil konversi
              },
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_error.isNotEmpty)
              Center(child: Text(_error, style: const TextStyle(color: Colors.red)))
            else
              _buildConversionResults(),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionResults() {
    final amountIDR = double.tryParse(_idrController.text) ?? 0.0;
    
    return Column(
      children: [
        ConversionResultRow(
          currency: "USD",
          value: _convert(amountIDR, 'USD'),
          symbol: '\$',
        ),
        ConversionResultRow(
          currency: "EUR",
          value: _convert(amountIDR, 'EUR'),
          symbol: '€',
        ),
        ConversionResultRow(
          currency: "SGD",
          value: _convert(amountIDR, 'SGD'),
          symbol: 'S\$',
        ),
      ],
    );
  }
}

// Widget terpisah untuk baris hasil konversi
class ConversionResultRow extends StatelessWidget {
  final String currency;
  final double value;
  final String symbol;

  const ConversionResultRow({
    super.key,
    required this.currency,
    required this.value,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'en_US', symbol: '$symbol ', decimalDigits: 2);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(currency, style: const TextStyle(fontSize: 16)),
          Text(
            formatter.format(value),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}