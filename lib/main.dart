import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';

// 💡 WHY: This handler must be top-level. It listens for messages when the app is in the background or terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('Background message received: ${message.messageId}');
}

Future<void> main() async {
  // 💡 WHY: Ensures the Flutter framework is ready before we initialize Firebase.
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Register the background handler before running the app
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FCM Activity',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FCMService _fcmService = FCMService();
  String statusText = 'Waiting for a cloud message';
  String myToken = 'Loading token...';

  @override
  void initState() {
    super.initState();
    
    // Fetch the token so we can target this specific device from the Firebase Console
    _fcmService.getToken().then((token) {
      setState(() {
        myToken = token ?? 'No token generated';
      });
      debugPrint('FCM token: $token');
    });

    // Listen for incoming messages and update the UI
    _fcmService.initialize(onData: (message) {
      setState(() {
        // Fallback safely to prevent crashing if the payload is missing these keys
        statusText = message.notification?.title ?? 'Payload received without title';
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FCM Testing Hub')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              statusText,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const Text('Your Device Token:', style: TextStyle(fontWeight: FontWeight.bold)),
            SelectableText(myToken, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}