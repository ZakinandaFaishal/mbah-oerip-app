import 'package:flutter/material.dart';
import '../../theme.dart';

class DetailInfoSection extends StatelessWidget {
  final String categoryName;
  final String title;
  final String description;
  final String idrPriceText;

  const DetailInfoSection({
    super.key,
    required this.categoryName,
    required this.title,
    required this.description,
    required this.idrPriceText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          categoryName,
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.accentColor.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryOrange,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          idrPriceText,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryOrange,
          ),
        ),
      ],
    );
  }
}
