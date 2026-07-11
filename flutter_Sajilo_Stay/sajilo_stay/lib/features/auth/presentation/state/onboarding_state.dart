import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sajilo_stay/core/services/storage/user_session_service.dart';

class OnboardingNotifier extends Notifier<int> {
  @override
  int build() {
    return 0; // Current page index
  }

  void setPage(int pageIndex) {
    state = pageIndex;
  }
}

final onboardingPageProvider = NotifierProvider<OnboardingNotifier, int>(() {
  return OnboardingNotifier();
});

class OnboardingCompletedNotifier extends Notifier<bool> {
  late SharedPreferences _prefs;

  @override
  bool build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _prefs.getBool('onboarding_completed') ?? false;
  }

  Future<void> completeOnboarding() async {
    await _prefs.setBool('onboarding_completed', true);
    state = true;
  }
}

final onboardingCompletedProvider = NotifierProvider<OnboardingCompletedNotifier, bool>(() {
  return OnboardingCompletedNotifier();
});
