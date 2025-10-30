import 'package:flutter/material.dart';
import '../../theme.dart';

class VoucherBanner extends StatelessWidget {
  const VoucherBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: 120, // tinggi tetap, tanpa margin eksternal
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background image
            Image.network(
              'https://lh3.googleusercontent.com/gps-cs-s/AG0ilSzdAI_Iu8tmlg22T5ItelnRmdR3ncK94d8xs-CMuLPWvqGbNMrJx-57d7mMdXreBp2Kyfn_3oBC-93PdomzQ_Wpb66HqEJWjPegLa1IiA0A_F9uRPA0iytqCRSrecr4CmG5MV_umw=s680-w680-h510-rw',
              fit: BoxFit.cover,
            ),
            // Overlay gelap
            Container(color: Colors.black.withOpacity(0.35)),
            // Konten
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.confirmation_number_outlined,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'Gunakan Voucher',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Potongan hingga 30% untuk menu favoritmu',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryOrange,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {},
                    child: const Text('Pakai'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
