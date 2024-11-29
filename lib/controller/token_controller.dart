import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'dart:convert';

class TokenController extends GetxController {
  final _storage = const FlutterSecureStorage();
  final accessToken = RxnString();
  final refreshToken = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadTokens(); // โหลด token เมื่อเริ่มต้น
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'accessToken', value: accessToken);
    await _storage.write(key: 'refreshToken', value: refreshToken);
    this.accessToken.value = accessToken;
    this.refreshToken.value = refreshToken;
    print('Token saved: $accessToken and $refreshToken');
  }

  Future<void> loadTokens() async {
    final access = await _storage.read(key: 'accessToken');
    final refresh = await _storage.read(key: 'refreshToken');
    accessToken.value = access; // อัปเดตค่า token ใน controller
    refreshToken.value = refresh;
    print('Token loaded: ${accessToken.value}');
    print('Token loaded: ${refreshToken.value}');
    // final accessToken = await _storage.read(key: 'accessToken');
    // final oldRefreshToken = await _storage.read(key: 'refreshToken');
    if (accessToken.value == null) {
      // Get.snackbar('Error', 'No access token found.');
      return;
    }
    if (refreshToken.value == null) {
      // Get.snackbar('Error', 'No refresh token found.');
      return;
    }
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/users/refresh-token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'refresh_token': refreshToken.value,
        }),
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        var newAccessToken = jsonData['data']?['access_token'];
        await _storage.write(key: 'accessToken', value: newAccessToken);
        accessToken.value = newAccessToken;
        print('Token saved:');
      } else {
        Get.snackbar('แจ้งเตือน', 'การขอ Token ล้มเหลว');
        print(response.reasonPhrase);
        print(response.statusCode);
      }
    } catch (e) {
      // Get.snackbar('Error', 'An error occurred: ${e.toString()}');
      print('Error occurred: $e');
    }
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: 'accessToken');
    await Future.delayed(Duration(milliseconds: 100)); // รอเวลาเล็กน้อย
    accessToken.value = await _storage.read(key: 'accessToken'); // โหลดค่าใหม่
    print('Token after deletion: ${accessToken.value}');
  }
}
