import 'package:flutter/material.dart';
import '../widgets/home/voucher_banner.dart';

class VouchersScreen extends StatelessWidget {
  const VouchersScreen({super.key});

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad =
        kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom + 12;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Voucher & Promo'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPad),
        children: [
          VoucherBanner(
            title: 'Diskon 30% Ingkung Ayam',
            subtitle: 'Hemat hingga Rp 30.000. Minimal belanja Rp 100.000',
            imageUrl:
                'https://www.pesonaborobudur.com/assets/upload/galeri/Ingkung_Ayam.jpg',
            buttonLabel: 'Pakai',
            onTap: () => _toast(context, 'Voucher 30% diterapkan'),
          ),
          const SizedBox(height: 12),
          VoucherBanner(
            title: 'Cashback 10% QRIS',
            subtitle: 'Maksimal cashback Rp 20.000. Berlaku setiap Jumat',
            imageUrl:
                'https://cdn-oss.ginee.com/official/wp-content/uploads/2022/03/image-446-704-1024x307.png',
            buttonLabel: 'Klaim',
            onTap: () => _toast(context, 'Cashback 10% diklaim'),
          ),
          const SizedBox(height: 12),
          VoucherBanner(
            title: 'Gratis Ongkir',
            subtitle: 'Gratis ongkir hingga Rp 10.000 untuk area tertentu',
            imageUrl:
                'https://bigseller-1251220924.cos.accelerate.myqcloud.com/static/faq/2025/1740015181066427.jpg',
            buttonLabel: 'Pakai',
            onTap: () => _toast(context, 'Gratis ongkir diaktifkan'),
          ),
          const SizedBox(height: 12),
          VoucherBanner(
            title: 'Buy 1 Get 1',
            subtitle: 'Berlaku untuk minuman pilihan setiap akhir pekan',
            imageUrl:
                'https://adsumo.co/blog/wp-content/uploads/2025/07/Nama-nama-Minuman-Tradisional-Ini-Cocok-untuk-Peluang-Bisnis-Kuliner-512x341.webp',
            buttonLabel: 'Klaim',
            onTap: () => _toast(context, 'Promo B1G1 digunakan'),
          ),
        ],
      ),
    );
  }
}
