import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:laptop_harbor/utils/toast_msg.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  final Color primaryColor = const Color(0xff037EEE);
  bool _isSubmitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final email = _emailController.text.trim();

      try {
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        setState(() {
          _isSubmitted = true;
        });
        ToastMsg.showToastMsg(
            'If this email is registered, a reset link has been sent.');
      } catch (error) {
        // Handle unexpected errors gracefully (e.g., network issues)
        ToastMsg.showToastMsg('Something went wrong. Please try again later.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: primaryColor,
      body: Stack(
        children: [
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: Colors.white,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Forgot Password',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 40), // To balance spacing
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: width,
              height: height * 0.7,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      // Illustration or icon
                      Icon(
                        Icons.lock_reset,
                        size: 80,
                        color: primaryColor,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          _isSubmitted
                              ? 'We have sent a password reset link to your email. Please check your inbox.'
                              : 'Enter your email address and we will send you a link to reset your password',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      if (!_isSubmitted) ...[
                        // Email Field
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            prefixIcon: const Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: _submitForm,
                            child: const Text(
                              'Send Reset Link',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Success state
                        const SizedBox(height: 20),
                        Icon(
                          Icons.check_circle,
                          size: 60,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: const Text(
                              'Back to Login',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      // Back to login link
                      if (!_isSubmitted)
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          child: Text(
                            'Remember your password? Login',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:laptop_harbor/utils/toast_msg.dart';

// class ForgotPassword extends StatefulWidget {
//   const ForgotPassword({super.key});

//   @override
//   State<ForgotPassword> createState() => _ForgotPasswordState();
// }

// class _ForgotPasswordState extends State<ForgotPassword> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _emailController = TextEditingController();
//   final Color primaryColor = const Color(0xff037EEE);
//   bool _isSubmitted = false;
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     super.dispose();
//   }

//   Future<bool> _checkEmailExists(String email) async {
//     try {
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .where('email', isEqualTo: email)
//           .limit(1)
//           .get();

//       return querySnapshot.docs.isNotEmpty;
//     } catch (e) {
//       debugPrint('Error checking email: $e');
//       return false;
//     }
//   }

//   Future<void> _updateFirestorePassword(
//       String email, String newPassword) async {
//     try {
//       // Find the user document by email
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .where('email', isEqualTo: email)
//           .limit(1)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         final docId = querySnapshot.docs.first.id;
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(docId)
//             .update({'password': newPassword});
//       }
//     } catch (e) {
//       debugPrint('Error updating Firestore password: $e');
//     }
//   }

//   Future<void> _submitForm() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);
//     final email = _emailController.text.trim();

//     try {
//       // First check if email exists in Firestore
//       final emailExists = await _checkEmailExists(email);
//       if (!emailExists) {
//         ToastMsg.showToastMsg('Email not found. Please register first.');
//         setState(() => _isLoading = false);
//         return;
//       }

//       // If email exists, send password reset email
//       await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

//       // Store reset request timestamp in Firestore
//       final querySnapshot = await FirebaseFirestore.instance
//           .collection('users')
//           .where('email', isEqualTo: email)
//           .limit(1)
//           .get();

//       if (querySnapshot.docs.isNotEmpty) {
//         final docId = querySnapshot.docs.first.id;
//         await FirebaseFirestore.instance.collection('users').doc(docId).update({
//           'passwordResetRequested': FieldValue.serverTimestamp(),
//         });
//       }

//       setState(() {
//         _isSubmitted = true;
//         _isLoading = false;
//       });
//       ToastMsg.showToastMsg('Password reset link has been sent to your email.');
//     } on FirebaseAuthException catch (e) {
//       setState(() => _isLoading = false);
//       ToastMsg.showToastMsg('Error: ${e.message}');
//     } catch (error) {
//       setState(() => _isLoading = false);
//       ToastMsg.showToastMsg('Something went wrong. Please try again later.');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final width = MediaQuery.of(context).size.width;
//     final height = MediaQuery.of(context).size.height;

//     return Scaffold(
//       backgroundColor: primaryColor,
//       body: Stack(
//         children: [
//           Positioned(
//             top: 60,
//             left: 0,
//             right: 0,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.arrow_back),
//                     color: Colors.white,
//                     onPressed: () => Navigator.pop(context),
//                   ),
//                   const Text(
//                     'Forgot Password',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(width: 40), // To balance spacing
//                 ],
//               ),
//             ),
//           ),
//           Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               width: width,
//               height: height * 0.7,
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(30),
//                   topRight: Radius.circular(30),
//                 ),
//               ),
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const SizedBox(height: 40),
//                       // Illustration or icon
//                       Icon(
//                         Icons.lock_reset,
//                         size: 80,
//                         color: primaryColor,
//                       ),
//                       const SizedBox(height: 20),
//                       const Text(
//                         'Forgot Password?',
//                         style: TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 20.0),
//                         child: Text(
//                           _isSubmitted
//                               ? 'We have sent a password reset link to your email. Please check your inbox.'
//                               : 'Enter your email address and we will send you a link to reset your password',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 30),
//                       if (!_isSubmitted) ...[
//                         // Email Field
//                         TextFormField(
//                           controller: _emailController,
//                           keyboardType: TextInputType.emailAddress,
//                           decoration: InputDecoration(
//                             labelText: 'Email',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             prefixIcon: const Icon(Icons.email),
//                           ),
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your email';
//                             }
//                             if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                                 .hasMatch(value)) {
//                               return 'Please enter a valid email';
//                             }
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 30),
//                         // Submit Button
//                         SizedBox(
//                           width: double.infinity,
//                           height: 50,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: primaryColor,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             onPressed: _isLoading ? null : _submitForm,
//                             child: _isLoading
//                                 ? const CircularProgressIndicator(
//                                     color: Colors.white)
//                                 : const Text(
//                                     'Send Reset Link',
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 18,
//                                     ),
//                                   ),
//                           ),
//                         ),
//                       ] else ...[
//                         // Success state
//                         const SizedBox(height: 20),
//                         Icon(
//                           Icons.check_circle,
//                           size: 60,
//                           color: Colors.green,
//                         ),
//                         const SizedBox(height: 20),
//                         SizedBox(
//                           width: double.infinity,
//                           height: 50,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: primaryColor,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                             ),
//                             onPressed: () {
//                               Navigator.pushNamed(context, '/login');
//                             },
//                             child: const Text(
//                               'Back to Login',
//                               style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                       const SizedBox(height: 20),
//                       // Back to login link
//                       if (!_isSubmitted)
//                         TextButton(
//                           onPressed: () {
//                             Navigator.pushNamed(context, '/login');
//                           },
//                           child: Text(
//                             'Remember your password? Login',
//                             style: TextStyle(
//                               color: primaryColor,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
