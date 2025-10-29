import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '/theme.dart';
import '../providers/cart_provider.dart';

class MenuDetailScreen extends StatefulWidget {
  final MenuItem item;
  final String categoryName;

  const MenuDetailScreen({
    super.key,
    required this.item,
    required this.categoryName,
  });

  @override
  State<MenuDetailScreen> createState() => _MenuDetailScreenState();
}

class _MenuDetailScreenState extends State<MenuDetailScreen> {
  String _convert(double amount, String currency) {
    // Asumsi 1 USD = Rp 16.300
    const double rateUSD = 1.0 / 16300.0;
    // Asumsi 1 EUR = Rp 17.500
    const double rateEUR = 1.0 / 17500.0;
    // Asumsi 1 SGD = Rp 12.000
    const double rateSGD = 1.0 / 12000.0;

    double convertedValue = 0.0;

    switch (currency) {
      case "USD":
        convertedValue = amount * rateUSD;
        break;
      case "EUR":
        convertedValue = amount * rateEUR;
        break;
      case "SGD":
        convertedValue = amount * rateSGD;
        break;
    }

    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '$currency ',
      decimalDigits: 2,
    );
    return formatter.format(convertedValue);
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    final formattedPrice = currencyFormatter.format(widget.item.price);

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text(
          widget.item.name,
          style: TextStyle(color: AppTheme.primaryColor),
        ),
        backgroundColor: AppTheme.backgroundWhite,
        elevation: 0.5,
        iconTheme: IconThemeData(color: AppTheme.primaryColor),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Produk
            Image.network(
              widget.item.imageUrl,
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 300,
                color: Colors.grey[200],
                child: Icon(Icons.broken_image, color: Colors.grey, size: 60),
              ),
            ),

            // Detail Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nama Kategori
                  Text(
                    widget.categoryName,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.accentColor.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Nama Produk
                  Text(
                    widget.item.name,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Harga
                  Text(
                    formattedPrice,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Deskripsi
                  Text(
                    widget.item.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 24),

                  // --- WIDGET KONVERSI MATA UANG (Integrasi) ---
                  _buildCurrencyConverterWidget(),
                ],
              ),
            ),
          ],
        ),
      ),

      // Tombol Checkout/Pesan
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              context.read<CartProvider>().addItem(
                id: widget.item.id, // sesuaikan dengan model
                name: widget.item.name,
                imageUrl: widget.item.imageUrl,
                priceInIDR: widget.item.price,
                quantity: 1,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Ditambahkan ke keranjang')),
              );
            },
            child: const Text('Tambah ke Keranjang'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyConverterWidget() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Estimasi Harga (Mata Uang Asing)",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Column(
            children: [
              _buildCurrencyRow(
                "USD",
                _convert(widget.item.price.toDouble(), "USD"),
              ),
              _buildCurrencyRow(
                "EUR",
                _convert(widget.item.price.toDouble(), "EUR"),
              ),
              _buildCurrencyRow(
                "SGD",
                _convert(widget.item.price.toDouble(), "SGD"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyRow(String currency, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            currency,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            price,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
