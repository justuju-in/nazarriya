import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_logger.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  
  String get _baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    String? firstName,
    int? age,
    String? preferredLanguage,
    String? state,
  }) async {
    try {
      final url = '$_baseUrl/auth/register';
      final body = {
        'email': email,
        'password': password,
        'first_name': firstName,
        'age': age,
        'preferred_language': preferredLanguage,
        'state': state,
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
        final loginResult = await login(email: email, password: password);
        
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
    required String email,
    required String password,
  }) async {
    try {
      final url = '$_baseUrl/auth/login';
      final body = {
        'email': email,
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
    return token != null && user != null;
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
