import 'dart:convert';
import 'dart:convert' show base64Url, utf8;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_logger.dart';
import 'profile_service.dart'; // Added import for ProfileService
import 'config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<AuthResult> register({
    required String email,
    required String password,
    required String phoneNumber,
    String? firstName,
    int? age,
    String? gender,
    String? preferredLanguage,
    String? state,
    String? preferredBot,
  }) async {
    try {
      final url = '${AppConfig.authUrl}/register';
      final body = <String, dynamic>{
        'email': email,
        'password': password,
        'phone_number': phoneNumber,
        'first_name': firstName,
        'age': age,
        'gender': gender,
        'preferred_language': preferredLanguage,
        'state': state,
        'preferred_bot': preferredBot,
      };
      
      logger.d('Registering user: POST $url');
      logger.d('Request body: ${json.encode(body)}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        logger.i('Registration successful: ${userData['email']}');
        
        // After successful registration, automatically log in the user
        logger.i('Auto-login after registration for: ${userData['email']}');
        final loginResult = await login(emailOrPhone: email, password: password);
        
        if (loginResult.success) {
          logger.i('Auto-login successful after registration');
          return loginResult;
        } else {
          logger.w('Auto-login failed after registration, but registration succeeded');
          return AuthResult.success(userData);
        }
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['detail'] ?? 'Registration failed';
        logger.e('Registration failed (${response.statusCode}): $errorMessage');
        logger.e('Full error response: ${response.body}');
        return AuthResult.error(errorMessage);
      }
    } catch (e) {
      logger.e('Registration network error: $e');
      return AuthResult.error('Network error: $e');
    }
  }

  Future<AuthResult> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final url = '${AppConfig.authUrl}/login';
      final body = {
        'email_or_phone': emailOrPhone,
        'password': password,
      };
      
      logger.d('Logging in user: POST $url');
      logger.d('Request body: ${json.encode(body)}');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final token = data['access_token'];
        final user = data['user'];
        
        logger.i('Login successful: ${user['email']}');
        
        // Clear any existing profile data before storing new user data
        await ProfileService.clearProfile();
        
        // Store token and user data
        await _storeToken(token);
        await _storeUser(user);
        
        return AuthResult.success(user, token: token);
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['detail'] ?? 'Login failed';
        logger.e('Login failed (${response.statusCode}): $errorMessage');
        logger.e('Full error response: ${response.body}');
        return AuthResult.error(errorMessage);
      }
    } catch (e) {
      logger.e('Login network error: $e');
      return AuthResult.error('Network error: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    
    // Also clear local profile data to prevent showing previous user's settings
    await ProfileService.clearProfile();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    logger.d('Retrieved token: ${token != null ? 'exists' : 'null'}');
    return token;
  }

  Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    if (userData != null) {
      final user = json.decode(userData);
      logger.d('Retrieved user data: ${user['email']}');
      return user;
    }
    logger.d('No user data found in storage');
    return null;
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    final user = await getUser();
    logger.d('Checking login status - Token: ${token != null}, User: ${user != null}');
    
    if (token != null && user != null) {
      // Check if token is expired
      if (_isTokenExpired(token)) {
        logger.w('Token is expired, clearing credentials');
        await logout();
        return false;
      }
      return true;
    }
    return false;
  }

  Future<bool> refreshToken() async {
    try {
      final user = await getUser();
      if (user == null) return false;
      
      // For now, we'll just clear the expired token and ask user to login again
      // In a production app, you might want to implement refresh tokens
      logger.i('Token expired, user needs to login again');
      await logout();
      return false;
    } catch (e) {
      logger.e('Error refreshing token: $e');
      return false;
    }
  }

  Future<AuthResult> updateProfile({
    String? firstName,
    int? age,
    String? gender,
    String? preferredLanguage,
    String? state,
    String? preferredBot,
  }) async {
    try {
      final token = await getToken();
      if (token == null) {
        return AuthResult.error('Not authenticated');
      }

      final url = '${AppConfig.authUrl}/profile';
      final body = <String, dynamic>{};
      
      if (firstName != null) body['first_name'] = firstName;
      if (age != null) body['age'] = age;
      if (gender != null) body['gender'] = gender;
      if (preferredLanguage != null) body['preferred_language'] = preferredLanguage;
      if (state != null) body['state'] = state;
      if (preferredBot != null) body['preferred_bot'] = preferredBot;
      
      logger.d('Updating profile: PUT $url');
      logger.d('Request body: ${json.encode(body)}');
      
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      logger.d('Response status: ${response.statusCode}');
      logger.d('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final updatedUser = json.decode(response.body);
        logger.i('Profile update successful: ${updatedUser['email']}');
        
        // Update stored user data
        await _storeUser(updatedUser);
        
        return AuthResult.success(updatedUser);
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['detail'] ?? 'Profile update failed';
        logger.e('Profile update failed (${response.statusCode}): $errorMessage');
        logger.e('Full error response: ${response.body}');
        return AuthResult.error(errorMessage);
      }
    } catch (e) {
      logger.e('Profile update network error: $e');
      return AuthResult.error('Network error: $e');
    }
  }

  bool _isTokenExpired(String token) {
    try {
      // Decode JWT token to check expiration
      final parts = token.split('.');
      if (parts.length != 3) return true;
      
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);
      
      final exp = payloadMap['exp'];
      if (exp == null) return true;
      
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      
      logger.d('Token expires at: $expiry, current time: $now');
      return now.isAfter(expiry);
    } catch (e) {
      logger.e('Error checking token expiration: $e');
      return true; // Assume expired if we can't decode
    }
  }

  Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    logger.d('Token stored successfully');
  }

  Future<void> _storeUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user));
    logger.d('User data stored successfully: ${user['email']}');
  }
}

class AuthResult {
  final bool success;
  final Map<String, dynamic>? user;
  final String? token;
  final String? error;

  AuthResult.success(this.user, {this.token}) 
    : success = true, error = null;
  
  AuthResult.error(this.error) 
    : success = false, user = null, token = null;
}
