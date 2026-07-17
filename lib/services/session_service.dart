import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class SessionService {
  static const String _sessionTokenKey = 'session_token';
  static const String _sessionCreatedAtKey = 'session_created_at';
  static const Duration _sessionDuration = Duration(days: 1);

  /// Create a new session token
  static Future<void> createSession() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().toIso8601String();
    await prefs.setString(_sessionTokenKey, _generateToken());
    await prefs.setString(_sessionCreatedAtKey, now);
  }

  /// Check if session is still valid (not expired)
  static Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_sessionTokenKey);
    final createdAt = prefs.getString(_sessionCreatedAtKey);

    if (token == null || createdAt == null) {
      return false;
    }

    try {
      final createdDateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final diff = now.difference(createdDateTime);

      return diff < _sessionDuration;
    } catch (e) {
      debugPrint('Error checking session validity: $e');
      return false;
    }
  }

  /// Clear session (logout)
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionTokenKey);
    await prefs.remove(_sessionCreatedAtKey);
  }

  /// Generate a random session token
  static String _generateToken() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Get remaining session time
  static Future<Duration?> getRemainingTime() async {
    final prefs = await SharedPreferences.getInstance();
    final createdAt = prefs.getString(_sessionCreatedAtKey);

    if (createdAt == null) {
      return null;
    }

    try {
      final createdDateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final expireTime = createdDateTime.add(_sessionDuration);
      final remaining = expireTime.difference(now);

      return remaining.isNegative ? Duration.zero : remaining;
    } catch (e) {
      debugPrint('Error calculating remaining time: $e');
      return null;
    }
  }
}
