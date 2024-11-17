import 'dart:convert'; // Для конвертации байтов в строку
import 'dart:math'; // Для генерации случайных чисел
import 'package:encrypt/encrypt.dart' as encrypt;

class EncryptionHelper {
  static final _key = encrypt.Key.fromUtf8('my32lengthsupersecretnooneknows1');

  static encrypt.IV _generateIV() {
    final random = Random.secure();
    final iv = List<int>.generate(16, (i) => random.nextInt(256));
    return encrypt.IV.fromLength(16); 
  }

  static String encryptPassword(String password) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final iv = _generateIV(); 
    final encrypted = encrypter.encrypt(password, iv: iv);
    return json.encode({
      'encrypted': encrypted.base64,
      'iv': iv.base64, 
    });
  }


  static String decryptPassword(String encryptedData) {
    final data = json.decode(encryptedData);
    final encryptedPassword = data['encrypted'];
    final iv = encrypt.IV.fromBase64(data['iv']);

    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final decrypted = encrypter.decrypt64(encryptedPassword, iv: iv);
    return decrypted;
  }
}
