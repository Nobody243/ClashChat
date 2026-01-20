import 'package:shared_preferences/shared_preferences.dart';

class AvatarPreferences {
  static const String _key = 'avatar_seed';

  /// Save avatar seed to SharedPreferences
  static Future<void> saveAvatar(String seed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, seed);
  }

  /// Load avatar seed from SharedPreferences (defaults to 'Felix')
  static Future<String> loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key) ?? 'Felix';
  }

  /// Clear avatar preference
  static Future<void> clearAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
