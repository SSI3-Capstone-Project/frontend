import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../controller/token_controller.dart';

class DeleteCardController extends GetxController {
  final tokenController = Get.find<TokenController>();

  var isLoading = false.obs;

  Future<void> deleteCard(String cardId) async {
    try {
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading.value = false;
        return;
      }
      final token = tokenController.accessToken.value;
      isLoading(true);

      final response = await http.delete(
        Uri.parse('${dotenv.env['API_URL']}/user/credit-cards/$cardId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // แทนที่ด้วยโทเค็นจริง
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar('สำเร็จ', 'ลบบัตรสำเร็จ');
      } else {
        Get.snackbar('ผิดพลาด', 'ไม่สามารถลบบัตรได้: ${jsonDecode(response.body)['message']}');
      }
    } catch (e) {
      Get.snackbar('ข้อผิดพลาด', 'เกิดข้อผิดพลาด: $e');
    } finally {
      isLoading(false);
    }
  }
}
