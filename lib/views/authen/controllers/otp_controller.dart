import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class OTPController extends GetxController {
  // State variables
  var isLoading = false.obs; // ใช้ RxBool สำหรับสถานะการโหลด
  // var responseMessage = ''.obs; // เก็บข้อความตอบกลับ

  // Function สำหรับส่ง OTP
  Future<bool> sendOTP(String email) async {
    // เริ่มแสดงสถานะ Loading
    isLoading.value = true;

    try {
      // URL ของ API
      final url = Uri.parse('${dotenv.env['API_URL']}/email/send-otp');

      // Body ของคำร้อง
      final body = {'email': email};

      // Header (ถ้าจำเป็น)
      final headers = {'Content-Type': 'application/json'};

      // ส่งคำร้อง POST
      final response = await http.post(
        url,
        body: jsonEncode(body),
        headers: headers,
      );

      // ตรวจสอบสถานะการตอบกลับ
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'];
        print('--------------------------------------------------------------');
        print(message);
        print('--------------------------------------------------------------');
        // Get.snackbar('สำเร็จ', 'รหัส OTP ถูกส่งไปยังอีเมลปลายทางแล้ว');
        // isLoading.value = false;
        // return true;
        if (message == 'Email is already registered') {
          Get.snackbar('แจ้งเตือน', 'อีเมลนี้ถูกลงทะเบียนไว้แล้ว');
          isLoading.value = false;
          return false;
        } else if (message == 'OTP has been sent to your email') {
          Get.snackbar('สำเร็จ', 'รหัส OTP ถูกส่งไปยังอีเมลปลายทางแล้ว');
          isLoading.value = false;
          return true;
        } else {
          Get.snackbar('แจ้งเตือน', 'เกิดข้อผิดพลาดในการส่งรหัส OTP');
          isLoading.value = false;
          return false;
        }
      } else if (response.statusCode == 409) {
        Get.snackbar('แจ้งเตือน', 'อีเมลนี้ถูกลงทะเบียนไว้แล้ว');
        isLoading.value = false;
        return false;
      } else {
        Get.snackbar('แจ้งเตือน', 'เกิดข้อผิดพลาดในการส่งรหัส OTP');
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      // Handle error
      print(
          '-----------------------------------------------------------------');
      print(e);
      Get.snackbar('Error', 'An error occurred. Please try again.');
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> reSendOTP(String email) async {
    // เริ่มแสดงสถานะ Loading
    isLoading.value = true;

    try {
      // URL ของ API
      final url = Uri.parse('${dotenv.env['API_URL']}/email/resend-otp');

      // Body ของคำร้อง
      final body = {'email': email};

      // Header (ถ้าจำเป็น)
      final headers = {'Content-Type': 'application/json'};

      // ส่งคำร้อง POST
      final response = await http.post(
        url,
        body: jsonEncode(body),
        headers: headers,
      );

      // ตรวจสอบสถานะการตอบกลับ
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final message = data['message'];
        print('--------------------------------------------------------------');
        print(message);
        print('--------------------------------------------------------------');
        // Get.snackbar('สำเร็จ', 'รหัส OTP ถูกส่งไปยังอีเมลปลายทางแล้ว');
        // isLoading.value = false;
        // return true;
        if (message == 'Email is already registered') {
          Get.snackbar('แจ้งเตือน', 'อีเมลนี้ถูกลงทะเบียนไว้แล้ว');
          isLoading.value = false;
          return false;
        } else if (message == 'OTP has been sent to your email') {
          Get.snackbar('สำเร็จ', 'รหัส OTP ใหม่ถูกส่งไปยังอีเมลปลายทางแล้ว');
          isLoading.value = false;
          return true;
        } else {
          Get.snackbar('แจ้งเตือน', 'เกิดข้อผิดพลาดในการส่งรหัส OTP ใหม่');
          isLoading.value = false;
          return false;
        }
      } else if (response.statusCode == 409) {
        Get.snackbar('แจ้งเตือน', 'อีเมลนี้ถูกลงทะเบียนไว้แล้ว');
        isLoading.value = false;
        return false;
      } else {
        Get.snackbar('แจ้งเตือน', 'เกิดข้อผิดพลาดในการส่งรหัส OTP ใหม่');
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      // Handle error
      print(
          '-----------------------------------------------------------------');
      print(e);
      Get.snackbar('Error', 'An error occurred. Please try again.');
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> verifyOTP(String email, String otp) async {
    // เริ่มแสดงสถานะ Loading
    isLoading.value = true;

    try {
      // URL ของ API
      final url = Uri.parse('${dotenv.env['API_URL']}/email/verify-otp');

      // Body ของคำร้อง
      final body = {'email': email, 'otp': otp};

      // Header (ถ้าจำเป็น)
      final headers = {'Content-Type': 'application/json'};

      // ส่งคำร้อง POST
      final response = await http.post(
        url,
        body: jsonEncode(body),
        headers: headers,
      );

      // ตรวจสอบสถานะการตอบกลับ
      if (response.statusCode == 200) {
        print('รหัส OTP ถูกส่งไปยังเมลปลายทางแล้ว');
        Get.snackbar('สำเร็จ', 'อีเมลของท่านถูกยืนยันเรียบร้อยแล้ว');
        isLoading.value = false;
        return true;
      } else {
        Get.snackbar('แจ้งเตือน', 'รหัสผ่าน OTP ไม่ถูกต้อง');
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      // Handle error
      print(
          '-----------------------------------------------------------------');
      print(e);
      Get.snackbar('Error', 'An error occurred. Please try again.');
      isLoading.value = false;
      return false;
    }
  }
}
