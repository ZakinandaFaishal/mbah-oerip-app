import 'package:flutter/material.dart';
import '../../theme.dart';

class CategoryFilterChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelected;

  const CategoryFilterChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, idx) {
        final cat = categories[idx];
        final isSelected = selected == cat;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          child: FilterChip(
            label: Text(
              cat,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.primaryOrange,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => onSelected(cat),
            backgroundColor: Colors.white,
            selectedColor: AppTheme.primaryOrange,
            side: BorderSide(
              color: isSelected
                  ? AppTheme.primaryOrange
                  : AppTheme.primaryOrange.withOpacity(.3),
            ),
          ),
        );
      },
    );
  }
}
