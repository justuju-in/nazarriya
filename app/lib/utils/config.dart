import 'package:flutter/foundation.dart';

class AppConfig {
  // Environment configuration - Change this to switch between environments
  static const Environment _currentEnvironment = Environment.local;
  
  // Server configurations for different environments
  static const Map<Environment, String> _serverUrls = {
    Environment.local: 'http://localhost:8000',
    Environment.androidEmulator: 'http://10.0.2.2:8000',
    Environment.remote: 'https://riya.justuju.in/', // Change this to your actual remote server URL
    Environment.staging: 'https://staging.your-server.com', // Optional: Add staging environment
  };
  
  // API endpoints
  static const String _authEndpoint = '/auth';
  static const String _chatEndpoint = '/api/chat';
  static const String _sessionsEndpoint = '/api/sessions';
  
  /// Get the base URL based on current environment and platform
  static String get baseUrl {
    // If using remote or staging, use those directly
    if (_currentEnvironment == Environment.remote || 
        _currentEnvironment == Environment.staging) {
      return _serverUrls[_currentEnvironment]!;
    }
    
    // For local environments, determine based on platform
    if (kIsWeb) {
      return _serverUrls[Environment.local]!;
    }
    
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _serverUrls[Environment.androidEmulator]!;
    }
    
    return _serverUrls[Environment.local]!;
  }
  
  /// Get the full auth endpoint URL
  static String get authUrl => '$baseUrl$_authEndpoint';
  
  /// Get the full chat endpoint URL
  static String get chatUrl => '$baseUrl$_chatEndpoint';
  
  /// Get the full sessions endpoint URL
  static String get sessionsUrl => '$baseUrl$_sessionsEndpoint';
  
  /// Check if using remote server
  static bool get isRemoteServer => _currentEnvironment == Environment.remote;
  
  /// Check if using staging server
  static bool get isStagingServer => _currentEnvironment == Environment.staging;
  
  /// Get current environment
  static Environment get currentEnvironment => _currentEnvironment;
  
  /// Get current server type for debugging
  static String get serverType {
    switch (_currentEnvironment) {
      case Environment.remote:
        return 'Remote';
      case Environment.staging:
        return 'Staging';
      case Environment.local:
        if (kIsWeb) return 'Local Web';
        if (defaultTargetPlatform == TargetPlatform.android) return 'Android Emulator';
        return 'Local Desktop';
      case Environment.androidEmulator:
        return 'Android Emulator (Forced)';
    }
  }
  
  /// Get server URL for a specific environment
  static String getServerUrl(Environment environment) {
    return _serverUrls[environment] ?? _serverUrls[Environment.local]!;
  }
}

/// Environment types for different server configurations
enum Environment {
  local,
  androidEmulator,
  remote,
  staging,
}
