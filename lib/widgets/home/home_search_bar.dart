import 'package:flutter/material.dart';
import '../../theme.dart';

class HomeSearchBar extends StatelessWidget {
  final VoidCallback onDirectionTap;
  const HomeSearchBar({super.key, required this.onDirectionTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              hintText: 'Cari menu favorit…',
              prefixIcon: const Icon(Icons.search),
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
            onTap: () {
              // Navigator.push(context, MaterialPageRoute(builder: (_) => const MenuScreen()));
            },
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
