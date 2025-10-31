import 'package:flutter/material.dart';
import '../../theme.dart';

class ProfileActionsCard extends StatelessWidget {
  final VoidCallback onFeedback;
  final VoidCallback onLogout;
  const ProfileActionsCard({
    super.key,
    required this.onFeedback,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.lightbulb_outline,
              color: AppTheme.primaryOrange,
            ),
            title: const Text('Saran & Kesan Kuliah'),
            trailing: const Icon(Icons.chevron_right),
            onTap: onFeedback,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.logout, color: AppTheme.primaryRed),
            title: const Text(
              'Logout',
              style: TextStyle(color: AppTheme.primaryRed),
            ),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
