import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // ใช้สำหรับเก็บ token อย่างปลอดภัย

class TokenController extends GetxController {
  final _storage = const FlutterSecureStorage();
  final accessToken = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadTokens(); // โหลด token เมื่อเริ่มแอป
  }

  Future<void> saveTokens(String accessToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    this.accessToken.value = accessToken;
  }

  Future<void> loadTokens() async {
    accessToken.value = await _storage.read(key: 'accessToken');
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: 'accessToken');
    accessToken.value = null;
  }
}
