import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  // Make sure if a user is not logged in and somehow lands on /AdminHome, you redirect them back:
  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Delayed to avoid navigation errors on build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/auth');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // SIGNOUT FUNCTION
    Future<void> signOutUser(BuildContext context) async {
      await FirebaseAuth.instance.signOut();

      // Go back to Auth or Splash screen
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AdminHome'),
        actions: [
          IconButton(
              onPressed: () {
                signOutUser(context);
              },
              icon: Icon(Icons.logout_rounded)),
        ],
      ),
    );
  }
}
