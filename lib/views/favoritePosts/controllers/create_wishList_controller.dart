import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

import 'package:mbea_ssi3_front/controller/token_controller.dart';

class CreateWishListController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var isLoading = false.obs;

  Future<bool> createWishList(String userId, String postId) async {
    isLoading.value = true;
    
    try {
      // ดึง Token ปัจจุบัน
      final token = tokenController.accessToken.value;

      // สร้างคำขอ MultipartRequest
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${dotenv.env['API_URL']}/wishlist/$userId/$postId'),
      );

      // เพิ่ม Header Authorization
      request.headers['Authorization'] = 'Bearer $token';

      // ส่งคำขอไปยังเซิร์ฟเวอร์
      var response = await request.send();

      // ตรวจสอบสถานะคำขอ
      if (response.statusCode == 200 || response.statusCode == 201) {
        // คำขอสำเร็จ
        Get.snackbar("สำเร็จ", "สร้าง wish list แล้ว");
        return true;
      } else {
        // คำขอล้มเหลว
        var responseBody = await response.stream.bytesToString();
        print('Error: ${response.statusCode}, Body: $responseBody');
        return false;
      }
    } catch (e) {
      // จัดการข้อผิดพลาด
      print('Exception occurred: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
