import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'app_logger.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  // Key storage keys
  static const String _encryptionKeyKey = 'encryption_key';
  static const String _keyIdKey = 'key_id';
  static const String _saltKey = 'encryption_salt';

  /// Store encryption key securely
  static Future<void> storeEncryptionKey(String key, String keyId) async {
    try {
      await _storage.write(key: _encryptionKeyKey, value: key);
      await _storage.write(key: _keyIdKey, value: keyId);
      logger.i('Encryption key stored securely');
    } catch (e) {
      logger.e('Failed to store encryption key: $e');
      rethrow;
    }
  }

  /// Retrieve encryption key
  static Future<String?> getEncryptionKey() async {
    try {
      final key = await _storage.read(key: _encryptionKeyKey);
      if (key != null) {
        logger.d('Encryption key retrieved successfully');
      }
      return key;
    } catch (e) {
      logger.e('Failed to retrieve encryption key: $e');
      return null;
    }
  }

  /// Get key ID
  static Future<String?> getKeyId() async {
    try {
      return await _storage.read(key: _keyIdKey);
    } catch (e) {
      logger.e('Failed to retrieve key ID: $e');
      return null;
    }
  }

  /// Store encryption salt
  static Future<void> storeSalt(String salt) async {
    try {
      await _storage.write(key: _saltKey, value: salt);
      logger.d('Encryption salt stored');
    } catch (e) {
      logger.e('Failed to store salt: $e');
      rethrow;
    }
  }

  /// Retrieve encryption salt
  static Future<String?> getSalt() async {
    try {
      return await _storage.read(key: _saltKey);
    } catch (e) {
      logger.e('Failed to retrieve salt: $e');
      return null;
    }
  }

  /// Check if encryption key exists
  static Future<bool> hasEncryptionKey() async {
    try {
      final key = await _storage.read(key: _encryptionKeyKey);
      return key != null;
    } catch (e) {
      logger.e('Failed to check encryption key existence: $e');
      return false;
    }
  }

  /// Clear all encryption data (for logout)
  static Future<void> clearEncryptionData() async {
    try {
      await _storage.delete(key: _encryptionKeyKey);
      await _storage.delete(key: _keyIdKey);
      await _storage.delete(key: _saltKey);
      logger.i('Encryption data cleared');
    } catch (e) {
      logger.e('Failed to clear encryption data: $e');
    }
  }

  /// Clear all stored data
  static Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      logger.i('All secure storage cleared');
    } catch (e) {
      logger.e('Failed to clear secure storage: $e');
    }
  }
}
