import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';
import 'secure_storage.dart';

class EncryptionService {
  static const String _keyId = 'flutter_app_key';
  static const String _algorithm = 'AES-256-GCM';
  
  /// Initialize encryption for the current user
  static Future<void> initializeEncryption() async {
    try {
      final existingKey = await SecureStorage.getEncryptionKey();
      
      if (existingKey == null) {
        // Generate a new encryption key
        final key = _generateEncryptionKey();
        final keyId = DateTime.now().millisecondsSinceEpoch.toString();
        await SecureStorage.storeEncryptionKey(key, keyId);
      }
    } catch (e) {
      print('Failed to initialize encryption: $e');
    }
  }
  
  /// Clear encryption data on logout
  static Future<void> clearEncryption() async {
    try {
      await SecureStorage.clearEncryptionData();
    } catch (e) {
      print('Failed to clear encryption: $e');
    }
  }
  
  /// Generate a fixed encryption key that matches the server
  static String _generateEncryptionKey() {
    // Use a fixed key that matches what the server expects
    // This is a 32-byte key encoded as base64
    return "cGxhY2Vob2xkZXJfa2V5XzMyX2J5dGVzX2xvbmdfZm8=";
  }
  
  /// Encrypt a message
  static Future<Map<String, dynamic>> encryptMessage(String message) async {
    try {
      final keyBase64 = await SecureStorage.getEncryptionKey();
      
      if (keyBase64 == null) {
        throw Exception('Encryption key not found');
      }
      
      final key = Key.fromBase64(keyBase64);
      final iv = IV.fromSecureRandom(12);
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      
      final encrypted = encrypter.encrypt(message, iv: iv);
      
      // Create metadata
      final metadata = {
        'algorithm': _algorithm,
        'key_id': _keyId,
        'iv': base64Encode(iv.bytes),
        'created_at': DateTime.now().toIso8601String(),
      };
      
      // Calculate content hash on the plaintext (not encrypted data)
      // Use UTF-8 encoding to match server's hash calculation
      final contentHash = sha256.convert(utf8.encode(message)).toString();
      
      return {
        'encrypted_message': base64Encode(encrypted.bytes),
        'encryption_metadata': metadata,
        'content_hash': contentHash,
      };
    } catch (e) {
      print('Failed to encrypt message: $e');
      rethrow;
    }
  }
  
  /// Decrypt a message from API response
  static Future<String> decryptFromApiResponse(Map<String, dynamic> response) async {
    try {
      final encryptedResponse = response['encrypted_response'] as String?;
      final encryptionMetadata = response['encryption_metadata'] as Map<String, dynamic>?;
      final contentHash = response['content_hash'] as String?;
      
      if (encryptedResponse == null || encryptionMetadata == null || contentHash == null) {
        throw Exception('Missing encryption fields in response');
      }
      
      // Decrypt the message first
      final encryptedBytes = base64.decode(encryptedResponse);
      final decryptedMessage = await decryptMessage(encryptedBytes, encryptionMetadata);
      
      // Verify content hash on the decrypted plaintext
      // Use UTF-8 encoding to match server's hash calculation
      final calculatedHash = sha256.convert(utf8.encode(decryptedMessage)).toString();
      if (calculatedHash != contentHash) {
        throw Exception('Content hash verification failed');
      }
      
      return decryptedMessage;
    } catch (e) {
      print('Failed to decrypt API response: $e');
      rethrow;
    }
  }
  
  /// Decrypt a message using metadata
  static Future<String> decryptMessage(Uint8List encryptedData, Map<String, dynamic> metadata) async {
    try {
      final keyBase64 = await SecureStorage.getEncryptionKey();
      
      if (keyBase64 == null) {
        throw Exception('Encryption key not found');
      }
      
      final key = Key.fromBase64(keyBase64);
      final ivBase64 = metadata['iv'] as String?;
      
      if (ivBase64 == null) {
        throw Exception('No IV found in encryption metadata');
      }
      
      final iv = IV.fromBase64(ivBase64);
      final encrypter = Encrypter(AES(key, mode: AESMode.gcm));
      
      final encrypted = Encrypted(encryptedData);
      final decrypted = encrypter.decrypt(encrypted, iv: iv);
      
      return decrypted;
    } catch (e) {
      print('Failed to decrypt message: $e');
      rethrow;
    }
  }
}
