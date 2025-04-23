import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:laptop_harbor/core/app_colors.dart';
import 'package:laptop_harbor/utils/toast_msg.dart';
import 'package:shared_preferences/shared_preferences.dart';

// class ProfileSection extends StatefulWidget {
//   const ProfileSection({super.key});

//   @override
//   State<ProfileSection> createState() => _ProfileSectionState();
// }

// class _ProfileSectionState extends State<ProfileSection> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();

//   bool _isLoading = true;
//   bool _isSaving = false;

//   @override
//   void initState() {
//     super.initState();
//     loadUserDetails();
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     super.dispose();
//   }

//   Future<void> loadUserDetails() async {
//     final user = FirebaseAuth.instance.currentUser;
//     final SharedPreferences prefs = await SharedPreferences.getInstance();

//     if (user != null) {
//       final uid = user.uid;
//       final doc =
//           await FirebaseFirestore.instance.collection('users').doc(uid).get();

//       if (doc.exists) {
//         final data = doc.data()!;
//         _nameController.text = data['name'] ?? '';
//         _emailController.text = data['email'] ?? '';
//         _phoneController.text = data['phone'] ?? '';

//         await prefs.setString('name', _nameController.text);
//         await prefs.setString('email', _emailController.text);
//         await prefs.setString('phone', _phoneController.text);
//       } else {
//         _nameController.text = prefs.getString('name') ?? '';
//         _emailController.text = prefs.getString('email') ?? '';
//         _phoneController.text = prefs.getString('phone') ?? '';
//       }
//     }

//     setState(() {
//       _isLoading = false;
//     });
//   }

// // 🔐 Password Dialog Function:
//   Future<String?> _showPasswordDialog() async {
//     String password = '';
//     return showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text('Re-authenticate'),
//         content: TextField(
//           autofocus: true,
//           obscureText: true,
//           onChanged: (value) => password = value,
//           decoration: InputDecoration(labelText: 'Enter your password'),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(),
//             child: Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(password),
//             child: Text('Confirm'),
//           ),
//         ],
//       ),
//     );
//   }

//   // Future<void> _saveProfile() async {
//   //   if (_formKey.currentState!.validate()) {
//   //     setState(() => _isSaving = true);

//   //     final name = _nameController.text.trim();
//   //     final email = _emailController.text.trim();
//   //     final phone = _phoneController.text.trim();

//   //     final user = FirebaseAuth.instance.currentUser;
//   //     final SharedPreferences prefs = await SharedPreferences.getInstance();

//   //     if (user != null) {
//   //       final uid = user.uid;

//   //       await FirebaseFirestore.instance.collection('users').doc(uid).update({
//   //         'name': name,
//   //         'email': email,
//   //         'phone': phone,
//   //       });

//   //       await prefs.setString('name', name);
//   //       await prefs.setString('email', email);
//   //       await prefs.setString('phone', phone);

//   //       ToastMsg.showToastMsg('Profile updated successfully!');
//   //       await Future.delayed(Duration(seconds: 1));
//   //       Navigator.pushReplacementNamed(context, '/home');
//   //     }

//   //     setState(() => _isSaving = false);
//   //   }
//   // }

//   // NEW GPT PROVIDED
//   Future<void> _saveProfile() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isSaving = true);

//       final name = _nameController.text.trim();
//       final email = _emailController.text.trim();
//       final phone = _phoneController.text.trim();

//       final user = FirebaseAuth.instance.currentUser;
//       final SharedPreferences prefs = await SharedPreferences.getInstance();

//       try {
//         if (user != null) {
//           final uid = user.uid;

//           // Update Firestore
//           await FirebaseFirestore.instance.collection('users').doc(uid).update({
//             'name': name,
//             'email': email,
//             'phone': phone,
//           });

//           // Update Firebase Auth display name
//           await user.updateDisplayName(name);

//           // Update Firebase Auth email if it's changed
//           if (email != user.email) {
//             try {
//               await user.verifyBeforeUpdateEmail(email);
//             } on FirebaseAuthException catch (e) {
//               if (e.code == 'requires-recent-login') {
//                 final password = await _showPasswordDialog();
//                 if (password != null) {
//                   final credential = EmailAuthProvider.credential(
//                       email: user.email!, password: password);
//                   await user.reauthenticateWithCredential(credential);
//                   await user
//                       .verifyBeforeUpdateEmail(email); // Retry email update
//                 } else {
//                   throw Exception("Reauthentication cancelled");
//                 }
//               } else {
//                 throw e;
//               }
//             }
//           }

//           // Save to local storage
//           await prefs.setString('name', name);
//           await prefs.setString('email', email);
//           await prefs.setString('phone', phone);

//           ToastMsg.showToastMsg('Profile updated successfully!');
//           await Future.delayed(Duration(seconds: 1));
//           Navigator.pushReplacementNamed(context, '/home');
//         }
//       } on FirebaseAuthException catch (e) {
//         ToastMsg.showToastMsg('Error: ${e.message}');
//       } catch (e) {
//         ToastMsg.showToastMsg('An unexpected error occurred.');
//       }

//       setState(() => _isSaving = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final primaryColor = AppColors.blue;
//     final screenWidth = MediaQuery.of(context).size.width;

//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: primaryColor,
//         title: Text("Edit Profile", style: TextStyle(color: Colors.white)),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator())
//           : Stack(
//               children: [
//                 SingleChildScrollView(
//                   padding: EdgeInsets.symmetric(
//                       horizontal: screenWidth * 0.07, vertical: 30),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       children: [
//                         Stack(
//                           alignment: Alignment.bottomRight,
//                           children: [
//                             CircleAvatar(
//                               radius: 60,
//                               backgroundImage: AssetImage('assets/user.jpg'),
//                             ),
//                             Positioned(
//                               bottom: 4,
//                               right: 4,
//                               child: GestureDetector(
//                                 onTap: () {
//                                   // TODO: Add image picker
//                                 },
//                                 child: Container(
//                                   padding: EdgeInsets.all(6),
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     color: primaryColor,
//                                   ),
//                                   child: Icon(Icons.edit,
//                                       color: Colors.white, size: 18),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         SizedBox(height: 30),

//                         // Name
//                         TextFormField(
//                           controller: _nameController,
//                           decoration: _inputDecoration("Name", Icons.person),
//                           validator: (value) => value == null || value.isEmpty
//                               ? 'Please enter your name'
//                               : null,
//                         ),
//                         SizedBox(height: 20),

//                         // Email
//                         TextFormField(
//                           controller: _emailController,
//                           decoration: _inputDecoration("Email", Icons.email),
//                           keyboardType: TextInputType.emailAddress,
//                           validator: (value) {
//                             if (value == null || value.isEmpty) {
//                               return 'Please enter your email';
//                             }
//                             if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
//                                 .hasMatch(value)) {
//                               return 'Invalid email';
//                             }
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 20),

//                         // Phone
//                         TextFormField(
//                           controller: _phoneController,
//                           decoration: _inputDecoration("Phone", Icons.phone),
//                           keyboardType: TextInputType.phone,
//                           inputFormatters: [
//                             FilteringTextInputFormatter.digitsOnly
//                           ],
//                           validator: (value) {
//                             if (value == null || value.isEmpty)
//                               return 'Please enter your phone number';
//                             if (value.length < 10 || value.length > 15)
//                               return 'Enter a valid phone number';
//                             return null;
//                           },
//                         ),
//                         SizedBox(height: 40),

//                         ElevatedButton(
//                           onPressed: _isSaving ? null : _saveProfile,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: primaryColor,
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: 50, vertical: 14),
//                             shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(12)),
//                           ),
//                           child: _isSaving
//                               ? SizedBox(
//                                   height: 20,
//                                   width: 20,
//                                   child: CircularProgressIndicator(
//                                     color: Colors.white,
//                                     strokeWidth: 2,
//                                   ),
//                                 )
//                               : Text("Save", style: TextStyle(fontSize: 16)),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }

//   InputDecoration _inputDecoration(String label, IconData icon) {
//     return InputDecoration(
//       prefixIcon: Icon(icon, color: AppColors.blue),
//       labelText: label,
//       labelStyle: TextStyle(color: Colors.grey[700]),
//       border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//       focusedBorder: OutlineInputBorder(
//         borderSide: BorderSide(color: AppColors.blue, width: 2),
//         borderRadius: BorderRadius.circular(12),
//       ),
//     );
//   }
// }

class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isLoading = true;
  bool _isSaving = false;
  String? _originalEmail; // Store the original email for comparison

  @override
  void initState() {
    super.initState();
    loadUserDetails();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> loadUserDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (user != null) {
      final uid = user.uid;
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _originalEmail = user.email; // Store the original auth email

        await prefs.setString('name', _nameController.text);
        await prefs.setString('email', _emailController.text);
        await prefs.setString('phone', _phoneController.text);
      } else {
        _nameController.text = prefs.getString('name') ?? '';
        _emailController.text = prefs.getString('email') ?? '';
        _phoneController.text = prefs.getString('phone') ?? '';
        _originalEmail = user.email;
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<String?> _showPasswordDialog() async {
    String password = '';
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Re-authentication Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('For security, please enter your current password:'),
            const SizedBox(height: 16),
            TextField(
              autofocus: true,
              obscureText: true,
              onChanged: (value) => password = value,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(password),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final name = _nameController.text.trim();
    final newEmail = _emailController.text.trim();
    final phone = _phoneController.text.trim();

    final user = FirebaseAuth.instance.currentUser;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    try {
      if (user != null) {
        final uid = user.uid;
        bool emailChanged = newEmail != _originalEmail;

        // 1. Update Firestore first (less critical operation)
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'name': name,
          'email': newEmail,
          'phone': phone,
        });

        // 2. Update display name in Firebase Auth
        await user.updateDisplayName(name);

        // 3. Handle email update if changed
        if (emailChanged) {
          try {
            // First try to update directly
            await user.verifyBeforeUpdateEmail(newEmail);
            ToastMsg.showToastMsg(
                'Verification email sent to your new address. Please verify.');
          } on FirebaseAuthException catch (e) {
            if (e.code == 'requires-recent-login') {
              // Need reauthentication
              final password = await _showPasswordDialog();
              if (password == null) {
                throw Exception('Reauthentication cancelled');
              }

              // Create auth credential
              final credential = EmailAuthProvider.credential(
                email: user.email!,
                password: password,
              );

              // Reauthenticate
              await user.reauthenticateWithCredential(credential);

              // Retry email update
              await user.verifyBeforeUpdateEmail(newEmail);
              ToastMsg.showToastMsg(
                  'Verification email sent to your new address. Please verify.');
            } else {
              throw e; // Re-throw other auth errors
            }
          }
        }

        // Update local storage
        await prefs.setString('name', name);
        await prefs.setString('email', newEmail);
        await prefs.setString('phone', phone);

        ToastMsg.showToastMsg('Profile updated successfully!');
        if (!mounted) return;
        Navigator.pop(context); // Go back instead of replacing to home
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Error updating profile: ${e.message}';
      if (e.code == 'email-already-in-use') {
        errorMessage = 'This email is already in use by another account.';
      }
      ToastMsg.showToastMsg(errorMessage);
    } catch (e) {
      ToastMsg.showToastMsg('An error occurred: $e');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = AppColors.blue;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title:
            const Text("Edit Profile", style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.07, vertical: 30),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            const CircleAvatar(
                              radius: 60,
                              backgroundImage: AssetImage('assets/user.jpg'),
                            ),
                            Positioned(
                              bottom: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  // TODO: Add image picker
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primaryColor,
                                  ),
                                  child: const Icon(Icons.edit,
                                      color: Colors.white, size: 18),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),

                        // Name
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration("Name", Icons.person),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter your name'
                              : null,
                        ),
                        const SizedBox(height: 20),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          decoration: _inputDecoration("Email", Icons.email),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return 'Invalid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        // Phone
                        TextFormField(
                          controller: _phoneController,
                          decoration: _inputDecoration("Phone", Icons.phone),
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your phone number';
                            }
                            if (value.length < 10 || value.length > 15) {
                              return 'Enter a valid phone number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 40),

                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 50, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text("Save",
                                  style: TextStyle(fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: AppColors.blue),
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700]),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.blue, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
