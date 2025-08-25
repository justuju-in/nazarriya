import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String _firstNameKey = 'profile_first_name';
  static const String _ageKey = 'profile_age';
  static const String _genderKey = 'profile_gender';
  static const String _languageKey = 'profile_language';
  static const String _stateKey = 'profile_state';
  static const String _botKey = 'profile_bot';

  // Get profile data
  static Future<Map<String, dynamic>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'firstName': prefs.getString(_firstNameKey),
      'age': prefs.getInt(_ageKey),
      'gender': prefs.getString(_genderKey),
      'preferredLanguage': prefs.getString(_languageKey),
      'state': prefs.getString(_stateKey),
      'preferredBot': prefs.getString(_botKey),
    };
  }

  // Save profile data
  static Future<bool> saveProfile({
    String? firstName,
    int? age,
    String? gender,
    String? preferredLanguage,
    String? state,
    String? preferredBot,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (firstName != null) {
      await prefs.setString(_firstNameKey, firstName);
    }
    if (age != null) {
      await prefs.setInt(_ageKey, age);
    }
    if (gender != null) {
      await prefs.setString(_genderKey, gender);
    }
    if (preferredLanguage != null) {
      await prefs.setString(_languageKey, preferredLanguage);
    }
    if (state != null) {
      await prefs.setString(_stateKey, state);
    }
    if (preferredBot != null) {
      await prefs.setString(_botKey, preferredBot);
    }
    
    return true;
  }

  // Clear profile data
  static Future<bool> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_firstNameKey);
    await prefs.remove(_ageKey);
    await prefs.remove(_genderKey);
    await prefs.remove(_languageKey);
    await prefs.remove(_stateKey);
    await prefs.remove(_botKey);
    return true;
  }

  // Helper methods to convert display values to backend codes
  static String? genderToCode(String? displayGender) {
    if (displayGender == null) return null;
    switch (displayGender) {
      case 'Male':
        return 'M';
      case 'Female':
        return 'F';
      case 'Other':
        return 'other';
      case 'Prefer not to say':
        return 'not_specified';
      default:
        return null;
    }
  }

  static String? codeToGender(String? code) {
    if (code == null) return null;
    switch (code) {
      case 'M':
        return 'Male';
      case 'F':
        return 'Female';
      case 'other':
        return 'Other';
      case 'not_specified':
        return 'Prefer not to say';
      default:
        return null;
    }
  }

  static String? botToCode(String? displayBot) {
    if (displayBot == null) return null;
    switch (displayBot) {
      case 'Nazar':
        return 'N';
      case 'Riya':
        return 'R';
      default:
        return null;
    }
  }

  static String? codeToBot(String? code) {
    if (code == null) return null;
    switch (code) {
      case 'N':
        return 'Nazar';
      case 'R':
        return 'Riya';
      default:
        return null;
    }
  }
}
