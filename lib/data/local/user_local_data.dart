import 'package:shared_preferences/shared_preferences.dart';

class UserLocalData {
  // 💾 Save user details locally using SharedPreferences
  // Phone number is optional and should include country code if provided
  static Future<void> saveUserData({
    required String name,
    required String email,
    String? phone, // Optional phone number
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    if (phone != null && phone.isNotEmpty) {
      await prefs.setString('phone', phone);
    }
  }

  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString('name'),
      'email': prefs.getString('email'),
      'phone': prefs.getString('phone'),
    };
  }

  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
