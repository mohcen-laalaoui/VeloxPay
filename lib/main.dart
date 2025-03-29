import 'package:flutter/material.dart';
import 'package:VeloxPay/UI/views/home/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:VeloxPay/firebase_options.dart';
import 'package:VeloxPay/UI/views/auth/signin.dart';
import 'package:VeloxPay/UI/views/dashboard/profile.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => HomePage(),
        '/login': (context) => SignInPage(),
        '/home': (context) => HomePage(),
        '/profile': (context) => ProfilePage(),
      },
      initialRoute: '/home',
      title: 'VeloxPay',
      debugShowCheckedModeBanner: false,
    );
  }
}
