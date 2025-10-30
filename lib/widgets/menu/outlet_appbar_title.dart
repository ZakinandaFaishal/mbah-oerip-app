import 'package:flutter/material.dart';
import '../../theme.dart';

class OutletAppBarTitle extends StatelessWidget {
  final String brandTitle;
  final List<String> outlets;
  final String selected;
  final ValueChanged<String> onChanged;

  const OutletAppBarTitle({
    super.key,
    required this.brandTitle,
    required this.outlets,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          brandTitle,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, size: 16, color: AppTheme.primaryOrange),
              const SizedBox(width: 4),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selected,
                  isDense: true,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                  ),
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                  items: outlets.map((o) {
                    return DropdownMenuItem<String>(value: o, child: Text(o));
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) onChanged(val);
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
