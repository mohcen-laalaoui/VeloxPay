import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:VeloxPay/UI/views/home/home.dart';
import 'package:VeloxPay/UI/views/auth/signin.dart';
import 'package:VeloxPay/UI/views/dashboard/profile.dart';
import 'package:VeloxPay/viewmodels/signin_viewmodel.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context) => AuthViewModel())],
      child: MaterialApp(
        routes: {
          '/': (context) => HomePage(),
          '/login': (context) => SignInPage(),
          '/home': (context) => HomePage(),
          '/profile': (context) => ProfilePage(),
        },
        initialRoute: '/home',
        title: 'VeloxPay',
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
