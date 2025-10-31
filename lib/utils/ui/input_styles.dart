import 'package:flutter/material.dart';
import '../../theme.dart';

InputDecoration buildInputDecoration(
  String label,
  IconData icon, {
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: AppTheme.primaryOrange),
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey, width: 1),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.grey, width: 1),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppTheme.primaryOrange, width: 2),
    ),
    filled: true,
    fillColor: Colors.white,
    labelStyle: const TextStyle(color: Colors.grey),
    floatingLabelStyle: const TextStyle(
      color: AppTheme.primaryOrange,
      fontWeight: FontWeight.w600,
    ),
  );
}
