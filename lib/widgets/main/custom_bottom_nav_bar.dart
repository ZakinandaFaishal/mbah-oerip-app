import 'package:flutter/material.dart';
import '../../theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: BottomAppBar(
          color: Colors.white,
          elevation: 0,
          notchMargin: 8,
          shape: const CircularNotchedRectangle(),
          child: SafeArea(
            top: false,
            child: SizedBox(
              height: 64, // naikkan tinggi agar tidak overflow
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _NavItem(
                          icon: Icons.restaurant_menu,
                          label: 'Menu',
                          index: 0,
                          isActive: currentIndex == 0,
                          onTap: onTap,
                        ),
                        const SizedBox(width: 28),
                        _NavItem(
                          icon: Icons.receipt_long,
                          label: 'Pesanan',
                          index: 1,
                          isActive: currentIndex == 1,
                          onTap: onTap,
                        ),
                      ],
                    ),
                    const SizedBox(width: 64), // ruang notch untuk FAB
                    Row(
                      children: [
                        _NavItem(
                          icon: Icons.confirmation_number_outlined,
                          label: 'Voucher',
                          index: 2,
                          isActive: currentIndex == 2,
                          onTap: onTap,
                        ),
                        const SizedBox(width: 28),
                        _NavItem(
                          icon: Icons.person_outline,
                          label: 'Profile',
                          index: 3,
                          isActive: currentIndex == 3,
                          onTap: onTap,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final bool isActive;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.primaryOrange : Colors.grey.shade500;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onTap(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6), // kecilkan padding vertikal
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
