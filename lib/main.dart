import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:laptop_harbor/presentation/providers/cart_provider.dart';
import 'package:laptop_harbor/presentation/providers/wishlist_provider.dart';
import 'package:laptop_harbor/presentation/views/admin/screens/products/admin_home.dart';

import 'package:provider/provider.dart';
import 'package:laptop_harbor/firebase_options.dart';
import 'package:laptop_harbor/presentation/views/authentication/auth.dart';
import 'package:laptop_harbor/presentation/views/authentication/forgot_password.dart';
import 'package:laptop_harbor/presentation/views/authentication/login.dart';
import 'package:laptop_harbor/presentation/views/authentication/select_profile_picture_screen.dart';
import 'package:laptop_harbor/presentation/views/authentication/signup.dart';
import 'package:laptop_harbor/presentation/views/drawer/change_password/change_password.dart';
import 'package:laptop_harbor/presentation/views/drawer/contact_us/contact_form.dart';
import 'package:laptop_harbor/presentation/views/drawer/help_faqs/faqs.dart';
import 'package:laptop_harbor/presentation/views/drawer/profile_section/profile_section.dart';
import 'package:laptop_harbor/presentation/views/navigation/navigation_wrapper.dart';
import 'package:laptop_harbor/presentation/views/on_boarding/on_boarding_screen.dart';
import 'package:laptop_harbor/presentation/views/splash_screen/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize notification service

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // theme: ThemeData(fontFamily: 'Inter'),
      // home: ProductsScreen(),
      initialRoute: '/splash-screen',

      routes: {
        // ADMIN - 1
        '/admin-home': (context) => AdminHome(),
        // AUTHENTICATION - 2
        '/auth': (context) => const Auth(),
        '/forgot-password': (context) => const ForgotPassword(),
        '/login': (context) => const Login(),
        '/select-profile-picture-screen': (context) =>
            const SelectProfilePictureScreen(),
        '/signup': (context) => const Signup(),
        // DRAWER - 3
        '/my-profile': (context) => ProfileSection(),
        '/change-password': (context) => ChangePassword(),
        '/contact-form': (context) => ContactForm(),
        '/faqs': (context) => Faqs(),

        // HOME - 4
        '/home': (context) => const NavigationWrapper(),
        // ON-BOARDING
        '/onboarding': (context) => const OnBoardingScreen(),
        // SPLASH SCREEN
        '/splash-screen': (context) => const SplashScreen(),
      },
    );
  }
}
