import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/core/services/storage/user_session_service.dart';

/// Holds the current user's locally-saved profile image path, shared across
/// tabs so updating it in the Profile tab also refreshes the Home header icon.
class ProfileImageNotifier extends Notifier<String?> {
  @override
  String? build() {
    return ref.read(userSessionServiceProvider).getProfileImagePath();
  }

  Future<void> setImagePath(String path) async {
    await ref.read(userSessionServiceProvider).saveProfileImagePath(path);
    state = path;
  }
}

final profileImageProvider =
    NotifierProvider<ProfileImageNotifier, String?>(ProfileImageNotifier.new);
