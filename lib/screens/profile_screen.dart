import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme.dart';
import 'feedback_screen.dart';
import 'login_screen.dart';
import '../widgets/profil/constants.dart';
import '../widgets/profil/profile_header.dart';
import '../widgets/profil/info_card.dart';
import '../widgets/profil/actions_card.dart';
import '../widgets/profil/edit_profile_sheet.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    ImageProvider avatar;
    final urlFromMeta = auth.profilePicPath; // sebenarnya URL dari metadata
    final urlFromState =
        auth.profilePicUrl; // URL terakhir yang diupload via updateProfile
    final useUrl = (urlFromState != null && urlFromState.isNotEmpty)
        ? urlFromState
        : (urlFromMeta != null && urlFromMeta.startsWith('http')
              ? urlFromMeta
              : null);

    if (useUrl != null) {
      avatar = NetworkImage(useUrl);
    } else {
      avatar = const NetworkImage(kDefaultAvatarUrl);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 72,
        leading: Navigator.of(context).canPop()
            ? Padding(
                padding: const EdgeInsets.only(left: 16),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade100,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              )
            : null,
        title: const Text(
          'Personal Info',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          TextButton(
            onPressed: () => showEditProfileSheet(context, auth),
            child: const Text(
              'Edit',
              style: TextStyle(
                color: AppTheme.primaryOrange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          ProfileHeader(
            avatar: avatar,
            displayName: auth.displayName,
            username: auth.username,
          ),
          const SizedBox(height: 12),
          ProfileInfoCard(
            displayName: auth.displayName,
            username: auth.username,
            phoneNumber: auth.phoneNumber,
          ),
          const SizedBox(height: 16),
          ProfileActionsCard(
            onFeedback: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FeedbackScreen()),
              );
            },
            onLogout: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
