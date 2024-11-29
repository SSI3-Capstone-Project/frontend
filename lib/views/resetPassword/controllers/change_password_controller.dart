import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mbea_ssi3_front/controller/token_controller.dart';

class ChangePasswordController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var isLoading = false.obs;
  var message = ''.obs;

  // จำเป็นต้องตั้ง accessToken ที่ได้รับจากการ login หรืออื่นๆ
  String? accessToken;

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    accessToken = tokenController.accessToken.value;
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    isLoading.value = true;
    // final url = Uri.parse('http://localhost:8080/api/user/change-password');

    // final body = {
    //   'old_password': oldPassword,
    //   'new_password': newPassword,
    // };

    try {
      await tokenController.loadTokens();
      print('---------------------------------------------------------------');
      print(oldPassword);
      print(newPassword);
      print('---------------------------------------------------------------');
      final token = tokenController.accessToken.value;
      if (accessToken == null) {
        Get.snackbar('Error', 'No access token found.');
        isLoading.value = false;
        return false;
      }
      final response = await http.put(
        Uri.parse('${dotenv.env['API_URL']}/users/change-password'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json' // แนบ Bearer Token
        },
        body: jsonEncode({
          'old_password': oldPassword,
          'new_password': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(utf8.decode(response.bodyBytes));
        message.value = responseData['message'] ?? 'Address added successfully';
        Get.snackbar("สำเร็จ", "คุณได้เปลี่ยนรหัสผ่านแล้ว");
        isLoading.value = false;
        return true;
      } else {
        final Map<String, dynamic> responseData =
            json.decode(utf8.decode(response.bodyBytes));
        if (responseData.containsKey('error') && responseData['error'] is Map) {
          final error = responseData['error'];
          if (error['message'] == 'Wrong password') {
            message.value = 'รหัสผ่านเดิมของคุณไม่ถูกต้อง';
          } else {
            message.value = error['message'] ?? 'An error occurred';
          }
        } else {
          message.value =
              responseData['message'] ?? 'Failed to change password';
        }

        print(responseData);
        Get.snackbar('แจ้งเตือน', message.value);
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("แจ้งเตือน", "An unexpected error occurred");
      return false;
    }
  }
}
