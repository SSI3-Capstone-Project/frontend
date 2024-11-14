import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // ใช้สำหรับเก็บ token อย่างปลอดภัย

class TokenController extends GetxController {
  final _storage = const FlutterSecureStorage();
  final accessToken = RxnString();
  final refreshToken = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadTokens(); // โหลด token เมื่อเริ่มแอป
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
    this.accessToken.value = accessToken;
    this.refreshToken.value = refreshToken;
  }

  Future<void> loadTokens() async {
    accessToken.value = await _storage.read(key: 'accessToken');
    refreshToken.value = await _storage.read(key: 'refreshToken');
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    accessToken.value = null;
    refreshToken.value = null;
  }
}
