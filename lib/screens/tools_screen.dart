import 'package:flutter/material.dart';
import '../widgets/currency_converter_widget.dart';
import '../widgets/time_converter_widget.dart';
import '/theme.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: Text(
          'Informasi Restoran',
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Jadwal & Estimasi
          const Text(
            'Jadwal & Estimasi Waktu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const RestaurantTimingWidget(),
          
          const SizedBox(height: 24),
          
          // Konversi Harga
          const Text(
            'Konversi Harga Menu',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const CurrencyConverterWidget(),
        ],
      ),
    );
  }
}