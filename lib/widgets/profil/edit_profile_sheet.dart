import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme.dart';
import 'constants.dart';

Future<void> showEditProfileSheet(
  BuildContext context,
  AuthProvider auth,
) async {
  final nameCtrl = TextEditingController(text: auth.displayName);
  final phoneCtrl = TextEditingController(text: auth.phoneNumber);
  String? avatarPath = auth.profilePicPath;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => StatefulBuilder(
      builder: (context, setSheetState) {
        Future<void> _pick(picker.ImageSource src) async {
          final x = await picker.ImagePicker().pickImage(
            source: src,
            imageQuality: 85,
          );
          if (x != null) setSheetState(() => avatarPath = x.path);
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            16 + MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Edit Profil',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 64,
                    backgroundColor: AppTheme.primaryOrange.withOpacity(.15),
                    backgroundImage:
                        (avatarPath != null && avatarPath!.isNotEmpty)
                        ? FileImage(File(avatarPath!))
                        : const NetworkImage(kDefaultAvatarUrl),
                  ),
                  Material(
                    color: Colors.white,
                    shape: const CircleBorder(),
                    child: IconButton(
                      iconSize: 22,
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      icon: const Icon(Icons.photo_camera_outlined),
                      onPressed: () async {
                        final src =
                            await showModalBottomSheet<picker.ImageSource>(
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(16),
                                ),
                              ),
                              builder: (bsCtx) => SafeArea(
                                child: Wrap(
                                  children: [
                                    ListTile(
                                      leading: const Icon(
                                        Icons.photo_library_outlined,
                                      ),
                                      title: const Text('Pilih dari Galeri'),
                                      onTap: () => Navigator.pop(
                                        bsCtx,
                                        picker.ImageSource.gallery,
                                      ),
                                    ),
                                    ListTile(
                                      leading: const Icon(
                                        Icons.photo_camera_outlined,
                                      ),
                                      title: const Text('Ambil dari Kamera'),
                                      onTap: () => Navigator.pop(
                                        bsCtx,
                                        picker.ImageSource.camera,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                            );
                        if (src != null) await _pick(src);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Nomor Telepon',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<AuthProvider>().updateProfile(
                      displayName: nameCtrl.text.trim(),
                      phoneNumber: phoneCtrl.text.trim(),
                      profilePicPath: avatarPath,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryOrange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Simpan'),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
