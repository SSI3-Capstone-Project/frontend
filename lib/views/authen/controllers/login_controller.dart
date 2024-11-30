import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/authen/models/login_model.dart';

class LoginController extends GetxController {
  final TokenController tokenController = Get.put(TokenController());
  var isLoading = false.obs;
  var loginToken = Rx<LoginToken?>(null);

  Future<bool> login(String username, String password) async {
    isLoading.value = true;
    try {
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/user/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tokenData = data['data'];
        final accessToken = tokenData['access_token'];
        final refreshToken = tokenData['refresh_token'];

        // บันทึก token ลงใน TokenController
        await tokenController.saveTokens(accessToken, refreshToken);

        Get.snackbar('สำเร็จ', 'เข้าสู่ระบบสำเร็จ');
        isLoading.value = false;
        return true;
      } else {
        Get.snackbar('แจ้งเตือน', 'ชื่อผู้ใช้งาน หรือ รหัสผ่าน ไม่ถูกต้อง');
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      print(
          '-----------------------------------------------------------------');
      print(e);
      Get.snackbar('Error', 'An error occurred. Please try again.');
      isLoading.value = false;
      return false;
    }
  }
}
