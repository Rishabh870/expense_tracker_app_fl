import 'package:encrypt/encrypt.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  // You must keep this key secure and dynamic in real production
  static final _key = Key.fromUtf8('ejf89iju4rjij358'); // 16 chars ✅
  static final _iv = IV.fromLength(16); // 16 bytes ✅
  static final _encrypter = Encrypter(AES(_key));

  static Future<void> storeTokens(
      String accessToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();

    final encryptedAccess = _encrypter.encrypt(accessToken, iv: _iv).base64;
    final encryptedRefresh = _encrypter.encrypt(refreshToken, iv: _iv).base64;

    await prefs.setString(_accessTokenKey, encryptedAccess);
    await prefs.setString(_refreshTokenKey, encryptedRefresh);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = prefs.getString(_accessTokenKey);
    if (encrypted == null) return null;

    try {
      return _encrypter.decrypt64(encrypted, iv: _iv);
    } catch (e) {
      return null; // Token corrupted or key mismatch
    }
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final encrypted = prefs.getString(_refreshTokenKey);
    if (encrypted == null) return null;

    try {
      return _encrypter.decrypt64(encrypted, iv: _iv);
    } catch (e) {
      return null;
    }
  }

  static Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
  }
}
