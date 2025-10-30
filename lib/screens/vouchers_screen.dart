import 'package:flutter/material.dart';
import '../theme.dart';

class VouchersScreen extends StatelessWidget {
  const VouchersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Voucher & Promo'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada voucher',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Dapatkan voucher spesial untuk pembelian berikutnya',
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Show available vouchers
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryOrange,
              ),
              child: const Text('Lihat Promo'),
            ),
          ],
        ),
      ),
    );
  }
}
