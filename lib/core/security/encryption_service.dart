import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

/// Comprehensive encryption service for medical data security
class EncryptionService {
  static final EncryptionService _instance = EncryptionService._internal();
  factory EncryptionService() => _instance;
  EncryptionService._internal();

  late final Encrypter _encrypter;
  late final Key _key;
  late final IV _iv;

  /// Initialize encryption with secure key generation
  Future<void> initialize() async {
    // Generate or retrieve encryption key
    _key = await _generateOrRetrieveKey();
    _iv = IV.fromSecureRandom(16);
    _encrypter = Encrypter(AES(_key));
  }

  /// Generate or retrieve encryption key securely
  Future<Key> _generateOrRetrieveKey() async {
    // In production, this should be retrieved from secure storage
    // For now, we'll generate a secure key
    final random = Random.secure();
    final keyBytes = List<int>.generate(32, (i) => random.nextInt(256));
    return Key(Uint8List.fromList(keyBytes));
  }

  /// Encrypt sensitive patient data
  String encryptPatientData(Map<String, dynamic> patientData) {
    final jsonString = jsonEncode(patientData);
    final encrypted = _encrypter.encrypt(jsonString, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypt patient data
  Map<String, dynamic> decryptPatientData(String encryptedData) {
    final encrypted = Encrypted.fromBase64(encryptedData);
    final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
    return jsonDecode(decrypted) as Map<String, dynamic>;
  }

  /// Encrypt payment card details
  String encryptCardDetails(Map<String, dynamic> cardDetails) {
    final jsonString = jsonEncode(cardDetails);
    final encrypted = _encrypter.encrypt(jsonString, iv: _iv);
    return encrypted.base64;
  }

  /// Decrypt payment card details
  Map<String, dynamic> decryptCardDetails(String encryptedData) {
    final encrypted = Encrypted.fromBase64(encryptedData);
    final decrypted = _encrypter.decrypt(encrypted, iv: _iv);
    return jsonDecode(decrypted) as Map<String, dynamic>;
  }

  /// Hash sensitive data for storage (one-way)
  String hashSensitiveData(String data) {
    final bytes = utf8.encode(data);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate secure random token
  String generateSecureToken() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Encode(bytes);
  }

  /// Encrypt file data
  Future<Uint8List> encryptFile(Uint8List fileData) async {
    final encrypted = _encrypter.encryptBytes(fileData, iv: _iv);
    return encrypted.bytes;
  }

  /// Decrypt file data
  Future<Uint8List> decryptFile(Uint8List encryptedData) async {
    final encrypted = Encrypted(encryptedData);
    final decrypted = _encrypter.decryptBytes(encrypted, iv: _iv);
    return Uint8List.fromList(decrypted);
  }

  /// Generate secure password hash with salt
  String hashPassword(String password, String salt) {
    final saltedPassword = password + salt;
    final bytes = utf8.encode(saltedPassword);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate secure salt
  String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (i) => random.nextInt(256));
    return base64Encode(bytes);
  }

  /// Verify password against hash
  bool verifyPassword(String password, String hash, String salt) {
    final hashedPassword = hashPassword(password, salt);
    return hashedPassword == hash;
  }
}
