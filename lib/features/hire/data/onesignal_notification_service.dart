import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

/// OneSignal push notifications. Works on Firebase Spark plan (no Cloud Functions).
/// Uses external user ID = Firebase uid for targeting. Configure Zapier to send
/// when hireRequests docs are created (see NOTIFICATIONS_SETUP.md).
class OneSignalNotificationService {
  OneSignalNotificationService();

  /// Your OneSignal App ID from onesignal.com. Replace with your actual ID.
  static const String appId = 'YOUR_ONESIGNAL_APP_ID';

  /// Call from main after Firebase init.
  static Future<void> initialize(
    void Function(String path) onNotificationTap,
  ) async {
    if (appId.isEmpty || appId == 'YOUR_ONESIGNAL_APP_ID') {
      if (kDebugMode) {
        debugPrint(
          'OneSignal: Set appId in onesignal_notification_service.dart',
        );
      }
      return;
    }

    OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(appId);

    OneSignal.Notifications.addClickListener((event) {
      onNotificationTap('/hire-requests');
    });
  }

  /// Call when user logs in. Sets external user ID = Firebase uid for Zapier targeting.
  Future<void> login(String uid) async {
    if (appId.isEmpty || appId == 'YOUR_ONESIGNAL_APP_ID') return;
    await OneSignal.login(uid);
  }

  /// Call when user logs out.
  Future<void> logout() async {
    await OneSignal.logout();
  }

  void syncWithAuthState(firebase_auth.User? user) {
    if (user != null) {
      login(user.uid);
    } else {
      logout();
    }
  }
}
