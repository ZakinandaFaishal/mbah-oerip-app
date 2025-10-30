import 'package:flutter/material.dart';
import '../../theme.dart';

class HomeSearchBar extends StatelessWidget {
  final VoidCallback onDirectionTap;
  final TextEditingController controller;
  final String query;
  final String hintText;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const HomeSearchBar({
    super.key,
    required this.onDirectionTap,
    required this.controller,
    required this.query,
    this.hintText = 'Cari menu...',
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: hintText,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      tooltip: 'Bersihkan',
                      icon: const Icon(Icons.close),
                      onPressed: onClear,
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 12,
              ),
            ),
            onChanged: onChanged,
            onSubmitted: onSubmitted,
          ),
        ),
        const SizedBox(width: 12),
        InkWell(
          onTap: onDirectionTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryOrange,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.directions, color: Colors.white),
          ),
        ),
      ],
    );
  }
}
