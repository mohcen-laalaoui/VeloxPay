import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:VeloxPay/firebase_options.dart';
import 'package:VeloxPay/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}
