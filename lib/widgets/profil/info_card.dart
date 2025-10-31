import 'package:flutter/material.dart';
import 'info_row.dart';

class ProfileInfoCard extends StatelessWidget {
  final String displayName;
  final String username;
  final String phoneNumber;

  const ProfileInfoCard({
    super.key,
    required this.displayName,
    required this.username,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ProfileInfoRow(
            icon: Icons.person_outline,
            label: 'Nama Lengkap',
            value: displayName.isEmpty ? '-' : displayName,
          ),
          const Divider(height: 1, indent: 56, endIndent: 16),
          ProfileInfoRow(
            icon: Icons.alternate_email,
            label: 'Username',
            value: username.isEmpty ? '-' : '@$username',
          ),
          const Divider(height: 1, indent: 56, endIndent: 16),
          ProfileInfoRow(
            icon: Icons.phone_outlined,
            label: 'Nomor Telepon',
            value: phoneNumber.isEmpty ? '-' : phoneNumber,
          ),
        ],
      ),
    );
  }
}
