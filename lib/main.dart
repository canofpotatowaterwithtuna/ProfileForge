import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'core/di/firebase_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/hire/data/onesignal_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final options = DefaultFirebaseOptions.currentPlatform;
  if (options != null) {
    await Firebase.initializeApp(options: options);
    await FirebaseAppCheck.instance.activate(
      androidProvider: kDebugMode
          ? AndroidProvider.debug
          : AndroidProvider.playIntegrity,
      appleProvider: kDebugMode
          ? AppleProvider.debug
          : AppleProvider.deviceCheck,
    );
  } else {
    await Firebase.initializeApp(); // Uses google-services.json / GoogleService-Info.plist
  }
  runApp(const ProviderScope(child: ProfileForgeApp()));
}

class ProfileForgeApp extends ConsumerWidget {
  const ProfileForgeApp({super.key});

  static bool _oneSignalInitScheduled = false;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authStateProvider, (prev, next) {
      next.whenData((user) {
        ref.read(oneSignalServiceProvider).syncWithAuthState(user);
      });
    });
    if (!_oneSignalInitScheduled) {
      _oneSignalInitScheduled = true;
      final router = ref.read(appRouterProvider);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await OneSignalNotificationService.initialize(
          (path) => router.go(path),
        );
      });
    }
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ProfileForge',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
