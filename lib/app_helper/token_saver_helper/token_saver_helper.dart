import 'package:shared_preferences/shared_preferences.dart';

class TokenHelper {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token");
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
  }

  static Future clear()async{
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }

  static Future<void> saveRegistrationToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("reg_token", token);
}

static Future<String?> getRegistrationToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("reg_token");
}

static Future<void> saveOtpSessionToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString("otp_session_token", token);
}

static Future<String?> getOtpSessionToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("otp_session_token");
}

  static Future<void> saveRefreshToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("refresh_token", token);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("refresh_token");
  }

  static Future<void> removeRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("refresh_token");
  }
}