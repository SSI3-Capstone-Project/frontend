import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:http/http.dart' as http;

import '../../../controller/token_controller.dart';

class EditCardDetailsController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var isLoading = false.obs;

  Future<void> updateCard(String cardId, String newName) async {
    try {
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading.value = false;
        return;
      }
      final token = tokenController.accessToken.value;
      isLoading.value = true;

      final response = await http.patch(
        Uri.parse('${dotenv.env['API_URL']}/user/credit-cards/$cardId'),
        headers: {
          "Content-Type": "application/json",
          'Authorization': 'Bearer $token', // ใส่ Token ถ้ามี
        },
        body: jsonEncode({"name": newName}),
      );

      if (response.statusCode == 200) {
        Get.snackbar(
          "สำเร็จ",
          "อัปเดตชื่อบัตรเรียบร้อยแล้ว",
          backgroundColor: Colors.grey.shade200,
        );
      } else {
        Get.snackbar(
          "ผิดพลาด",
          "ไม่สามารถอัปเดตข้อมูลได้",
          backgroundColor: Colors.grey.shade200,
        );
      }
    } catch (e) {
      Get.snackbar(
        "ข้อผิดพลาด",
        "เกิดข้อผิดพลาด: $e",
        backgroundColor: Colors.grey.shade200,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
