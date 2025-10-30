import 'package:flutter/material.dart';
import '../../theme.dart';

class VoucherBanner extends StatelessWidget {
  const VoucherBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1556745753-b2904692b3cd?q=80&w=1600&auto=format&fit=crop',
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(.6), Colors.transparent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.confirmation_number,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Gunakan Voucher',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Potongan hingga 30% untuk menu favoritmu',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryOrange,
                    ),
                    onPressed: () {},
                    child: const Text('Pakai'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
