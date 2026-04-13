import 'package:firebase_messaging/firebase_messaging.dart';

// 💡 WHY: Best practice is to keep the service as a separate class, not inline in your widget, to keep logic clear and testable.
class FCMService {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<void> initialize({required void Function(RemoteMessage) onData}) async {
    // Request permissions for iOS/Android 13+
    await messaging.requestPermission(alert: true, badge: true, sound: true);

    // 1. onMessage: Runs when the app is open and active in the foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      onData(message);
    });

    // 2. onMessageOpenedApp: Runs when the user taps a notification while the app is in the background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      onData(message);
    });

    // 3. getInitialMessage: Runs when the app starts because the user tapped a notification and the app was fully terminated
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      onData(initialMessage);
    }
  }

  Future<String?> getToken() {
    return messaging.getToken();
  }
}