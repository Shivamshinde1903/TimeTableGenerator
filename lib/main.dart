// core Flutter primitives
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ui3/pages/auth_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:ui3/pages/database.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// TODO: Add stream controller

import 'package:rxdart/rxdart.dart';
// used to pass messages from event handler to the UI
final _messageStreamController = BehaviorSubject<RemoteMessage>();
// TODO: Define the background message handler

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // TODO: Request permission

  final messaging = FirebaseMessaging.instance;

  final settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  if (kDebugMode) {
    print('Permission granted: ${settings.authorizationStatus}');
  }
  // TODO: Register with FCM
  // It requests a registration token for sending messages to users from your App server or other trusted server environment.
  String? token = await messaging.getToken();

  if (kDebugMode) {
    print('Registration Token=$token');
  }
  // TODO: Set up foreground message handler

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (kDebugMode) {
      print('Handling a foreground message: ${message.messageId}');
      print('Message data: ${message.data}');
      print('Message notification: ${message.notification?.title}');
      print('Message notification: ${message.notification?.body}');
    }

    _messageStreamController.sink.add(message);
  });
  // TODO: Set up background message handler
  //createDatabaseAndAddData();
  addData();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthPage(),
    );
  }
}

// class _MyHomePageState extends State<MyHomePage> {
//   String _lastMessage = "";
//
//   _MyHomePageState() {
//     _messageStreamController.listen((message) {
//       setState(() {
//         if (message.notification != null) {
//           _lastMessage = 'Received a notification message:'
//               '\nTitle=${message.notification?.title},'
//               '\nBody=${message.notification?.body},'
//               '\nData=${message.data}';
//         } else {
//           _lastMessage = 'Received a data message: ${message.data}';
//         }
//       });
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text('Last message from Firebase Messaging:',
//                 style: Theme.of(context).textTheme.titleLarge),
//             Text(_lastMessage, style: Theme.of(context).textTheme.bodyLarge),
//           ],
//         ),
//       ),
//     );
//   }
// }
