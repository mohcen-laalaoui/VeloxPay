import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:financial/UI/views/auth/signin.dart';
import 'package:financial/UI/views/dashboard/profile.dart';
import 'package:financial/UI/views/home/home.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    errorBuilder: (context, state) => ErrorScreen(),

    redirect: (BuildContext context, GoRouterState state) {
      final bool loggedIn = FirebaseAuth.instance.currentUser != null;
      final bool isLoggingIn = state.uri.path == '/signin';

      if (!loggedIn && !isLoggingIn) return '/signin';

      if (loggedIn && isLoggingIn) return '/home';

      return null;
    },

    routes: [
      GoRoute(path: '/signin', builder: (context, state) => SignInPage()),
      GoRoute(path: '/home', builder: (context, state) => HomePage()),
      GoRoute(path: '/profile', builder: (context, state) => ProfilePage()),
    ],
  );
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Error')),
      body: Center(child: Text('Page not found')),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      title: 'VeloxPay',
      theme: ThemeData(primarySwatch: Colors.blue),
    );
  }
}
