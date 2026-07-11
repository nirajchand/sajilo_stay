import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sajilo_stay/app.dart';
import 'package:sajilo_stay/core/services/hive/hive_service.dart';
import 'package:sajilo_stay/core/services/image_cache/image_cache_service.dart';
import 'package:sajilo_stay/core/services/storage/user_session_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService().init();
  await ImageCacheService().init();

  // Initialize Google Sign-In once.
  // serverClientId must be a WEB OAuth 2.0 client ID from your Google Cloud project
  // so the idToken returned can be verified server-side.
  // Replace the value below after setting up Firebase and downloading google-services.json.
  await GoogleSignIn.instance.initialize(
    serverClientId:
        '1038248094057-7jb5a8egvick1fha0gl7fh8vam2c37mm.apps.googleusercontent.com',
  );

  final sharedPrefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(sharedPrefs)],
      child: const MyApp(),
    ),
  );
}
