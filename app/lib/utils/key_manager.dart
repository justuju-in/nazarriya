import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'secure_storage.dart';
import 'app_logger.dart';

class KeyManager {
  static const int _keyLength = 32; // 256 bits for AES-256

  /// Generate a new encryption key and store it securely
  static Future<String> generateAndStoreKey(String userId, String password) async {
    try {
      // Generate a random key (for simplicity, not using password derivation)
      final key = _generateRandomBytes(_keyLength);
      final keyBase64 = base64Encode(key);
      
      // Generate a unique key ID
      final keyId = _generateKeyId(userId);
      
      // Store key securely
      await SecureStorage.storeEncryptionKey(keyBase64, keyId);
      
      logger.i('Generated and stored new encryption key for user: $userId');
      return keyId;
    } catch (e) {
      logger.e('Failed to generate and store encryption key: $e');
      rethrow;
    }
  }

  /// Retrieve existing encryption key
  static Future<String?> getEncryptionKey() async {
    try {
      return await SecureStorage.getEncryptionKey();
    } catch (e) {
      logger.e('Failed to retrieve encryption key: $e');
      return null;
    }
  }

  /// Get the current key ID
  static Future<String?> getKeyId() async {
    try {
      return await SecureStorage.getKeyId();
    } catch (e) {
      logger.e('Failed to retrieve key ID: $e');
      return null;
    }
  }

  /// Check if encryption key exists
  static Future<bool> hasEncryptionKey() async {
    return await SecureStorage.hasEncryptionKey();
  }

  /// Generate random bytes
  static Uint8List _generateRandomBytes(int length) {
    final random = Random.secure();
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = random.nextInt(256);
    }
    return bytes;
  }

  /// Generate a unique key ID
  static String _generateKeyId(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random.secure().nextInt(10000);
    return '${userId}_${timestamp}_$random';
  }

  /// Rotate encryption key (generate new key)
  static Future<String> rotateKey(String userId, String password) async {
    try {
      logger.i('Rotating encryption key for user: $userId');
      return await generateAndStoreKey(userId, password);
    } catch (e) {
      logger.e('Failed to rotate encryption key: $e');
      rethrow;
    }
  }

  /// Clear all encryption keys (for logout)
  static Future<void> clearKeys() async {
    try {
      await SecureStorage.clearEncryptionData();
      logger.i('Encryption keys cleared');
    } catch (e) {
      logger.e('Failed to clear encryption keys: $e');
    }
  }

  /// Validate encryption key format
  static bool isValidKey(String? key) {
    if (key == null || key.isEmpty) return false;
    try {
      base64Decode(key);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get encryption metadata
  static Map<String, dynamic> getEncryptionMetadata(String keyId) {
    return {
      'algorithm': 'AES-256-GCM',
      'key_id': keyId,
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}