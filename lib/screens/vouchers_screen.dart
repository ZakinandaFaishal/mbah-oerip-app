import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../utils/shake_detector.dart';
import '../utils/snackbar_utils.dart';
import '../widgets/voucher/shake_promo_banner.dart';
import '../theme.dart';
import '../widgets/home/voucher_banner.dart';

class VouchersScreen extends StatefulWidget {
  const VouchersScreen({super.key});

  @override
  State<VouchersScreen> createState() => _VouchersScreenState();
}

class _VouchersScreenState extends State<VouchersScreen> {
  late final ShakeDetector _shake;
  bool _unlocked = false;
  String? _voucherCode;
  int? _discount;

  @override
  void initState() {
    super.initState();
    _shake = ShakeDetector(onShake: _onShake, threshold: 18.0);
    _shake.start();
  }

  @override
  void dispose() {
    _shake.stop();
    super.dispose();
  }

  void _onShake() {
    if (_unlocked) return;
    final percent = [10, 15, 20, 25, 30][Random().nextInt(5)];
    final ts = DateTime.now().millisecondsSinceEpoch
        .toRadixString(36)
        .toUpperCase();
    final code = 'SHAKE-${ts.substring(ts.length - 5)}';

    setState(() {
      _unlocked = true;
      _discount = percent;
      _voucherCode = code;
    });

    HapticFeedback.mediumImpact();
    showModernSnackBar(
      context,
      message: 'Voucher $code diskon $percent% dibuka!',
      icon: Icons.card_giftcard,
      color: Colors.green.shade600,
      actionLabel: 'Salin',
      onAction: () => Clipboard.setData(ClipboardData(text: code)),
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
        padding: EdgeInsets.fromLTRB(
          16,
          16,
          16,
          bottomPad,
        ), // gunakan bottomPad
        children: [
          ShakePromoBanner(
            unlocked: _unlocked,
            discount: _discount,
            onTapTest: _onShake, // tap untuk uji di emulator
          ),
          const SizedBox(height: 16),

          if (_unlocked)
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.local_offer, color: Colors.green),
                title: Text('$_discount% OFF - ${_voucherCode ?? ''}'),
                subtitle: const Text('Klaim hari ini saja. S&K berlaku.'),
                trailing: TextButton(
                  onPressed: () => Clipboard.setData(
                    ClipboardData(text: _voucherCode ?? ''),
                  ),
                  child: const Text('SALIN'),
                ),
              ),
            ),
          const SizedBox(height: 12),

          // Banner voucher sebelumnya (dipertahankan)
          VoucherBanner(
            title: 'Diskon 30% Ingkung Ayam',
            subtitle: 'Hemat hingga Rp 30.000. Minimal belanja Rp 100.000',
            imageUrl:
                'https://www.pesonaborobudur.com/assets/upload/galeri/Ingkung_Ayam.jpg',
            buttonLabel: 'Pakai',
            onTap: () => showModernSnackBar(
              context,
              message: 'Voucher 30% diterapkan',
              icon: Icons.local_offer,
              color: AppTheme.primaryOrange,
            ),
          ),
          const SizedBox(height: 12),
          VoucherBanner(
            title: 'Cashback 10% QRIS',
            subtitle: 'Maksimal cashback Rp 20.000. Berlaku setiap Jumat',
            imageUrl:
                'https://cdn-oss.ginee.com/official/wp-content/uploads/2022/03/image-446-704-1024x307.png',
            buttonLabel: 'Klaim',
            onTap: () => showModernSnackBar(
              context,
              message: 'Cashback 10% diklaim',
              icon: Icons.local_offer,
              color: AppTheme.primaryOrange,
            ),
          ),
          const SizedBox(height: 12),
          VoucherBanner(
            title: 'Gratis Ongkir',
            subtitle: 'Gratis ongkir hingga Rp 10.000 untuk area tertentu',
            imageUrl:
                'https://bigseller-1251220924.cos.accelerate.myqcloud.com/static/faq/2025/1740015181066427.jpg',
            buttonLabel: 'Pakai',
            onTap: () => showModernSnackBar(
              context,
              message: 'Gratis ongkir diaktifkan',
              icon: Icons.local_shipping_outlined,
              color: AppTheme.primaryOrange,
            ),
          ),
          const SizedBox(height: 12),
          VoucherBanner(
            title: 'Buy 1 Get 1',
            subtitle: 'Minuman pilihan setiap akhir pekan',
            imageUrl:
                'https://adsumo.co/blog/wp-content/uploads/2025/07/Nama-nama-Minuman-Tradisional-Ini-Cocok-untuk-Peluang-Bisnis-Kuliner-512x341.webp',
            buttonLabel: 'Klaim',
            onTap: () => showModernSnackBar(
              context,
              message: 'Promo B1G1 digunakan',
              icon: Icons.local_offer,
              color: AppTheme.primaryOrange,
            ),
          ),
        ],
      ),
    );
  }
}
