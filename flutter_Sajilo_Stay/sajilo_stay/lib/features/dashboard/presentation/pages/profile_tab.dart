import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sajilo_stay/core/constants/colors.dart';
import 'package:sajilo_stay/core/services/storage/user_session_service.dart';
import 'package:sajilo_stay/core/utils/snackbar_utils.dart';
import 'package:sajilo_stay/features/auth/presentation/state/auth_state.dart';
import 'package:sajilo_stay/features/dashboard/presentation/pages/legal_page.dart';
import 'package:sajilo_stay/features/dashboard/presentation/state/profile_image_state.dart';

class ProfileTab extends ConsumerStatefulWidget {
  const ProfileTab({super.key});

  @override
  ConsumerState<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends ConsumerState<ProfileTab> {
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 800,
        imageQuality: 85,
      );
      if (picked == null) return;

      // Copy into app storage so the path survives picker-cache cleanup.
      final dir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final saved = await File(picked.path).copy('${dir.path}/$fileName');

      // Update shared state so the Home header icon refreshes too.
      await ref.read(profileImageProvider.notifier).setImagePath(saved.path);

      if (!mounted) return;
      SnackbarUtils.showSuccess(context, 'Profile picture updated.');
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Could not update picture.');
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: kSurfaceLevel1,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: kNeutralColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined,
                  color: kSecondaryColor),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: kSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.camera_alt_outlined, color: kSecondaryColor),
              title: const Text(
                'Take a Photo',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: kSecondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.read(userSessionServiceProvider);
    final fullName = session.getCurrentUserFullName() ?? 'Mohamed Henedy';
    final email = session.getCurrentUserEmail() ?? 'user@sajilostay.com';
    final imagePath = ref.watch(profileImageProvider);
    final hasImage = imagePath != null && File(imagePath).existsSync();

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page label
            Text(
              'User Profile',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: kNeutralColor,
                  ),
            ),
            const SizedBox(height: 8),
            // Brand title
            Text(
              'Sajilo Stay',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 28),
            // Avatar + user info (horizontal)
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kSurfaceLevel2,
                        border: Border.all(
                          color: kAccentColor.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        image: hasImage
                            ? DecorationImage(
                                image: FileImage(File(imagePath)),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: hasImage
                          ? null
                          : const Icon(Icons.person,
                              color: kNeutralColor, size: 38),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _showImageSourceSheet,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: kAccentColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: kBackgroundColor, width: 2),
                          ),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: kNeutralColor,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Settings card
            Container(
              decoration: BoxDecoration(
                color: kSurfaceLevel1,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  _SettingsTile(
                    icon: Icons.shield_outlined,
                    label: 'Privacy Policy',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LegalPage.privacy()),
                    ),
                  ),
                  _Divider(),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    label: 'Terms & Conditions',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => LegalPage.terms()),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Logout button
            Container(
              decoration: BoxDecoration(
                color: kSurfaceLevel1,
                borderRadius: BorderRadius.circular(24),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A1A1A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: Color(0xFFEF4444), size: 18),
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444),
                  ),
                ),
                onTap: () => _confirmLogout(context, ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kSurfaceLevel1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Log out?',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: kNeutralColor,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: kNeutralColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authStateProvider.notifier).logout();
            },
            child: const Text(
              'Log out',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: Color(0xFFEF4444),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: kSurfaceLevel2,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: kSecondaryColor, size: 18),
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: kSecondaryColor,
              fontSize: 14,
            ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: kNeutralColor, size: 20),
      onTap: onTap,
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 20,
      endIndent: 20,
      color: kNeutralColor.withValues(alpha: 0.1),
    );
  }
}
