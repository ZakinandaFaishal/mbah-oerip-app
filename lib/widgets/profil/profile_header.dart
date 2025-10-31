import 'package:flutter/material.dart';
import '../../theme.dart';

class ProfileHeader extends StatelessWidget {
  final ImageProvider avatar;
  final String displayName;
  final String username;
  const ProfileHeader({
    super.key,
    required this.avatar,
    required this.displayName,
    required this.username,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 56,
              backgroundColor: AppTheme.primaryOrange.withOpacity(.15),
              backgroundImage: avatar,
            ),
            const SizedBox(height: 12),
            Text(
              displayName.isEmpty ? 'Pengguna' : displayName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              username.isEmpty ? '' : '@$username',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
