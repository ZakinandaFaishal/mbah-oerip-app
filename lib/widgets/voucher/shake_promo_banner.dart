import 'package:flutter/material.dart';
import '../../theme.dart';

class ShakePromoBanner extends StatelessWidget {
  final bool unlocked;
  final int? discount;
  final VoidCallback onTapTest;

  const ShakePromoBanner({
    super.key,
    required this.unlocked,
    this.discount,
    required this.onTapTest,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTapTest, // untuk testing di emulator
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryOrange.withOpacity(.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primaryOrange.withOpacity(.25)),
        ),
        child: Row(
          children: [
            Icon(
              unlocked ? Icons.card_giftcard : Icons.vibration_rounded,
              color: AppTheme.primaryOrange,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                unlocked
                    ? 'Voucher spesial terbuka! Diskon ${discount ?? 0}% tersedia hari ini.'
                    : 'Goyangkan HP Anda untuk mendapatkan voucher diskon hari ini!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
