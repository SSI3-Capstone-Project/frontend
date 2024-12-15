import 'dart:convert'; // สำหรับ jsonEncode
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';

class DeleteAccountController extends GetxController {
  final tokenController = Get.find<TokenController>();

  var isLoading = false.obs;

  Future<bool> deleteAccount(String password) async {
    isLoading.value = true;

    if (tokenController.accessToken.value == null) {
      Get.snackbar('Error', 'No access token found.');
      isLoading.value = false;
      return false;
    }

    try {
      final token = tokenController.accessToken.value;
      // สร้างคำขอ HTTP แบบ DELETE
      final request = http.Request(
        'DELETE',
        Uri.parse('${dotenv.env['API_URL']}/user'),
      );

      // เพิ่ม headers
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Content-Type'] = 'application/json';

      // เพิ่ม body
      request.body = jsonEncode({
        'password': password, // ส่ง password ใน body
      });

      // ส่งคำขอและรับ response
      final response = await http.Client().send(request);

      // อ่าน response body
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        Get.snackbar('สำเร็จ', 'บัญชีได้ถูกลบออกไปแล้ว');
        isLoading.value = false;
        return true;
      } else {
        Get.snackbar(
          'แจ้งเตือน',
          'เกิดข้อผิดพลาดในการลบบัญชี: ${response.statusCode}\n$responseBody',
        );
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      Get.snackbar('แจ้งเตือน', 'เกิดข้อผิดพลาด: $e');
      isLoading.value = false;
      return false;
    }
  }
}
