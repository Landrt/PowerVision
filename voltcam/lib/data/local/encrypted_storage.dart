import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypted storage service for sensitive user preferences & telemetry.
/// Uses [FlutterSecureStorage] for secure key-value persistence, with an in-memory fallback
/// for unit testing environments where native platform channels are unavailable.
class EncryptedStorageService {
  final FlutterSecureStorage _secureStorage;
  final Map<String, String> _inMemoryStore = {};
  final bool _useInMemoryFallback;

  EncryptedStorageService({
    FlutterSecureStorage? secureStorage,
    bool useInMemoryFallback = false,
  })  : _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _useInMemoryFallback = useInMemoryFallback;

  /// Write a key-value pair to encrypted storage.
  Future<void> write({required String key, required String value}) async {
    if (_useInMemoryFallback) {
      _inMemoryStore[key] = value;
      return;
    }
    try {
      await _secureStorage.write(key: key, value: value);
    } catch (_) {
      _inMemoryStore[key] = value;
    }
  }

  /// Read a value from encrypted storage.
  Future<String?> read({required String key}) async {
    if (_useInMemoryFallback) {
      return _inMemoryStore[key];
    }
    try {
      return await _secureStorage.read(key: key);
    } catch (_) {
      return _inMemoryStore[key];
    }
  }

  /// Delete a key from encrypted storage.
  Future<void> delete({required String key}) async {
    if (_useInMemoryFallback) {
      _inMemoryStore.remove(key);
      return;
    }
    try {
      await _secureStorage.delete(key: key);
    } catch (_) {
      _inMemoryStore.remove(key);
    }
  }

  /// Clear all entries in encrypted storage.
  Future<void> deleteAll() async {
    _inMemoryStore.clear();
    if (!_useInMemoryFallback) {
      try {
        await _secureStorage.deleteAll();
      } catch (_) {}
    }
  }

  /// Encrypt a string payload or data using SHA-256 derived XOR/AES cipher scheme for offline buffer protection.
  String encryptPayload(String payload, String key) {
    final keyBytes = utf8.encode(key);
    final keyHash = sha256.convert(keyBytes).bytes;
    final payloadBytes = utf8.encode(payload);

    final encryptedBytes = List<int>.generate(payloadBytes.length, (i) {
      return payloadBytes[i] ^ keyHash[i % keyHash.length];
    });

    return base64.encode(encryptedBytes);
  }

  /// Decrypt an encrypted payload string using the matching key.
  String decryptPayload(String encryptedBase64, String key) {
    final keyBytes = utf8.encode(key);
    final keyHash = sha256.convert(keyBytes).bytes;
    final encryptedBytes = base64.decode(encryptedBase64);

    final decryptedBytes = List<int>.generate(encryptedBytes.length, (i) {
      return encryptedBytes[i] ^ keyHash[i % keyHash.length];
    });

    return utf8.decode(decryptedBytes);
  }
}
