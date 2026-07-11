import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sajilo_stay/core/navigation/app_navigator.dart';
import 'package:sajilo_stay/features/auth/presentation/pages/splash_screen.dart';
import 'package:sajilo_stay/theme/theme_data.dart';
import 'package:sajilo_stay/theme/theme_provider.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Sajilo Stay',
      theme: getApplicationLightTheme(),
      darkTheme: getApplicationDarkTheme(),
      themeMode: themeMode,
      home: const SplashScreen(),
    );
  }
}
