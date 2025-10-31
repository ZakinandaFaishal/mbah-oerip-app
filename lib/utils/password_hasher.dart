import 'dart:convert';
import 'package:cryptography/cryptography.dart' as crypt;

class PasswordHasher {
  static const String _pepper = 'PEPPER_CHANGE_ME';
  static const List<int> _appSalt = [
    0x51, 0xA2, 0xC3, 0xD4, 0xE5, 0x16, 0x27, 0x38,
    0x49, 0x5A, 0x6B, 0x7C, 0x8D, 0x9E, 0xAF, 0xB0,
  ];

  static final crypt.Pbkdf2 _pbkdf2 = crypt.Pbkdf2(
    macAlgorithm: crypt.Hmac.sha256(),
    iterations: 120000,
    bits: 256,
  );

  static Future<String> hash(String password) async {
    final secret = crypt.SecretKey(utf8.encode('$password$_pepper'));
    final key = await _pbkdf2.deriveKey(secretKey: secret, nonce: _appSalt);
    final bytes = await key.extractBytes();
    return base64UrlEncode(bytes);
  }
}