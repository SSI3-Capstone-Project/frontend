import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TokenController extends GetxController with WidgetsBindingObserver {
  final _storage = const FlutterSecureStorage();
  final accessToken = RxnString();
  final refreshToken = RxnString();
  Timer? _timer;
  bool isLoading = false;
  final _mutex = RxBool(false);

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      reloadTokens();
      restartTokenRefresh();
    }
  }

  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this);
    stopTokenRefresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      reloadTokens();
      restartTokenRefresh();
    } else if (state == AppLifecycleState.paused) {
      stopTokenRefresh();
    }
  }

  Future<void> reloadTokens() async {
    if (_mutex.value) return;
    _mutex.value = true;

    try {
      final access = await _storage.read(key: 'accessToken');
      final refresh = await _storage.read(key: 'refreshToken');

      if (access == null || refresh == null) {
        accessToken.value = null;
        refreshToken.value = null;
        // Get.snackbar('Error', 'No tokens found. Skipping refresh.');
        print('(Token) No tokens found. Skipping refresh.');
        return;
      }

      refreshToken.value = refresh;

      if (isTokenExpired(refresh)) {
        await deleteTokens();
        // Get.offAllNamed('/login');
        print('(Token) Refresh token data expired.');
        Get.snackbar('Error', 'Refresh token data expired.');
        return;
      }

      final response = await http
          .post(
            Uri.parse('${dotenv.env['API_URL']}/user/refresh-token'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'refresh_token': refresh}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tokenData = data['data'];

        if (tokenData != null &&
            tokenData['access_token'] != null &&
            tokenData['refresh_token'] != null) {
          await saveTokens(
              tokenData['access_token'], tokenData['refresh_token']);
          // Get.snackbar('Success', 'Tokens refreshed successfully.');
        } else {
          print('(Token) Invalid token data received.');
          Get.snackbar('Error', 'Invalid token data received.');
        }
      } else if (response.statusCode == 401) {
        await deleteTokens();
        // Get.offAllNamed('/login');
        print('(Token) Invalid refresh token data.');
        Get.snackbar('Error', 'Invalid refresh token data.');
      } else {
        print('(Token) Failed to refresh tokens: ${response.body}');
        Get.snackbar('Error', 'Failed to refresh tokens: ${response.body}');
      }
    } catch (e) {
      print('(Token) Error during token refresh: $e');
      Get.snackbar('Error', 'Error during token refresh: $e');
    } finally {
      _mutex.value = false;
    }
  }

  bool isTokenExpired(String token) {
    try {
      final payload =
          base64Url.decode(base64Url.normalize(token.split('.')[1]));
      final expiry = json.decode(utf8.decode(payload))['exp'];
      final now = DateTime.now().millisecondsSinceEpoch / 1000;
      print('----------------------------------------------------------------');
      print(expiry);
      print('----------------------------------------------------------------');
      return expiry < now;
    } catch (e) {
      print('(Token) Error during check token expired: $e');
      return true;
    }
  }

  Future<void> saveTokens(String newAccessToken, String newRefreshToken) async {
    try {
      final currentAccessToken = await _storage.read(key: 'accessToken');
      final currentRefreshToken = await _storage.read(key: 'refreshToken');

      if (currentAccessToken == newAccessToken &&
          currentRefreshToken == newRefreshToken) {
        print('(Token) Tokens are already up-to-date.');
        return;
      }

      await _storage.write(key: 'accessToken', value: newAccessToken);
      await _storage.write(key: 'refreshToken', value: newRefreshToken);

      accessToken.value = newAccessToken;
      refreshToken.value = newRefreshToken;
      print('(Token) Save new token success');

      restartTokenRefresh();
    } catch (e) {
      print('(Token) Error saving tokens: $e');
    }
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    accessToken.value = null;
    refreshToken.value = null;
  }

  void startTokenRefresh() {
    if (_timer != null && _timer!.isActive) {
      print('(Token) Token refresh is already running.');
      return;
    }
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      reloadTokens();
    });
  }

  void stopTokenRefresh() {
    _timer?.cancel();
    _timer = null;
  }

  void restartTokenRefresh() {
    stopTokenRefresh();
    startTokenRefresh();
  }
}
