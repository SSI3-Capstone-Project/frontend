import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

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
    print('Token saved: $accessToken');
  }

  Future<void> loadTokens() async {
    accessToken.value = await _storage.read(key: 'accessToken');
    print('Token loaded: ${accessToken.value}');
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: 'accessToken');
    await Future.delayed(Duration(milliseconds: 100)); // รอเวลาเล็กน้อย
    accessToken.value = await _storage.read(key: 'accessToken'); // โหลดค่าใหม่
    print('Token after deletion: ${accessToken.value}');
  }
}
