import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String _firstNameKey = 'profile_first_name';
  static const String _ageKey = 'profile_age';
  static const String _languageKey = 'profile_language';
  static const String _stateKey = 'profile_state';

  // Get profile data
  static Future<Map<String, dynamic>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'firstName': prefs.getString(_firstNameKey),
      'age': prefs.getInt(_ageKey),
      'preferredLanguage': prefs.getString(_languageKey),
      'state': prefs.getString(_stateKey),
    };
  }

  // Save profile data
  static Future<bool> saveProfile({
    String? firstName,
    int? age,
    String? preferredLanguage,
    String? state,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (firstName != null) {
      await prefs.setString(_firstNameKey, firstName);
    }
    if (age != null) {
      await prefs.setInt(_ageKey, age);
    }
    if (preferredLanguage != null) {
      await prefs.setString(_languageKey, preferredLanguage);
    }
    if (state != null) {
      await prefs.setString(_stateKey, state);
    }
    
    return true;
  }

  // Clear profile data
  static Future<bool> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firstNameKey);
    await prefs.remove(_ageKey);
    await prefs.remove(_languageKey);
    await prefs.remove(_stateKey);
    return true;
  }
}
