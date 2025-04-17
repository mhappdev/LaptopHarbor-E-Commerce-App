import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:laptop_harbor/firebase_options.dart';
import 'package:laptop_harbor/presentation/views/admin/admin_home.dart';
import 'package:laptop_harbor/presentation/views/authentication/auth.dart';
import 'package:laptop_harbor/presentation/views/authentication/forgot_password.dart';
import 'package:laptop_harbor/presentation/views/authentication/login.dart';
import 'package:laptop_harbor/presentation/views/authentication/signup.dart';
import 'package:laptop_harbor/presentation/views/home/home.dart';
import 'package:laptop_harbor/presentation/views/on_boarding/on_boarding_screen.dart';
import 'package:laptop_harbor/presentation/views/splash_screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(fontFamily: 'Inter'),
      // home: Auth(),
      initialRoute: '/splash-screen',
      routes: { 
        '/onboarding': (context) => const OnBoardingScreen(),
        '/splash-screen': (context) => const SplashScreen(),
        '/login': (context) => const Login(),
        '/signup': (context) => const Signup(),
        '/auth': (context) => const Auth(),
        '/forgot-password': (context) => const ForgotPassword(),
        '/home': (context) => const Home(),
        // ADMIN
        '/admin-home': (context) => const AdminHome(),

      },
    );
  }
}
