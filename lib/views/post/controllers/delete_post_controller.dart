import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';

class PostDeleteController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var isLoading = false.obs;

  Future<bool> deletePost(String postId) async {
    isLoading.value = true;
    if (tokenController.accessToken.value == null) {
      // Get.snackbar('Error', 'No access token found.');
      isLoading.value = false;
      return false;
    }
    try {
      final token = tokenController.accessToken.value;
      final response = await http.patch(
        Uri.parse('${dotenv.env['API_URL']}/posts/$postId'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          'สำเร็จ',
          'โพสต์ได้ถูกลบออกไปแล้ว',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading.value = false;
        return true;
      } else {
        Get.snackbar(
          'แจ้งเตือน',
          'เกิดข้อผิดพลาดในการลบโพสต์',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'แจ้งเตือน',
        'เกิดข้อผิดพลาด: $e',
        backgroundColor: Colors.grey.shade200,
      );
      isLoading.value = false;
      return false;
    }
  }
}
