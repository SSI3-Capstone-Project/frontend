import 'package:flutter/material.dart';
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
      var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tokenData = data['data'];
        final accessToken = tokenData['access_token'];
        final refreshToken = tokenData['refresh_token'];

        // บันทึก token ลงใน TokenController
        await tokenController.saveTokens(accessToken, refreshToken);

        Get.snackbar(
          'สำเร็จ',
          'เข้าสู่ระบบสำเร็จ',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading.value = false;
        return true;
      } else if (response.statusCode == 400) {
        print(jsonData);
        Get.snackbar(
          'แจ้งเตือน',
          'กรุณากรอกรหัสผ่านของท่าน',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading.value = false;
        return false;
      } else if (response.statusCode == 401) {
        print(jsonData);
        Get.snackbar(
          'แจ้งเตือน',
          'ชื่อผู้ใช้งาน หรือ รหัสผ่าน ไม่ถูกต้อง',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading.value = false;
        return false;
      } else if (response.statusCode == 404) {
        print(jsonData);
        Get.snackbar(
          'แจ้งเตือน',
          'กรุณากรอกชื่อผู้ใช้งานของท่าน',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading.value = false;
        return false;
      } else {
        print(jsonData);
        Get.snackbar(
          'แจ้งเตือน',
          'เกิดปัญหาระหว่างการเข้าสู่ระบบ',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      print(e);
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()} in LoginController',
        backgroundColor: Colors.grey.shade200,
      );
      isLoading.value = false;
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
