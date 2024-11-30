import 'dart:async'; // สำหรับ Timer
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TokenController extends GetxController with WidgetsBindingObserver {
  final _storage = const FlutterSecureStorage();
  final accessToken = RxnString();
  final refreshToken = RxnString();
  Timer? _timer; // ตัวแปร Timer
  bool isLoading = false;
  final _mutex = RxBool(false); // Mutex สำหรับป้องกันคำขอซ้อน

  // @override
  // void onInit() {
  //   super.onInit();
  //   WidgetsBinding.instance.addObserver(this); // สังเกตสถานะแอป
  //   reloadTokens(); // โหลด token ครั้งแรกเมื่อแอปเปิดใหม่
  //   restartTokenRefresh(); // เริ่มการนับเวลาใหม่เมื่อแอปเปิด
  // }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this); // สังเกตสถานะแอป

    // โหลด token เฉพาะเมื่อแอปอยู่ใน foreground
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      reloadTokens();
      restartTokenRefresh();
    }
  }

  @override
  void onClose() {
    super.onClose();
    WidgetsBinding.instance.removeObserver(this); // ยกเลิกการสังเกตสถานะแอป
    stopTokenRefresh(); // หยุด Timer เมื่อ Controller ถูกปิด
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // เมื่อแอปกลับมาใช้งาน
      print('App is back in foreground');
      reloadTokens(); // โหลด token ใหม่
      restartTokenRefresh(); // เริ่ม Timer ใหม่
    } else if (state == AppLifecycleState.paused) {
      // เมื่อแอปออกไป background
      print('App is in background');
      stopTokenRefresh(); // หยุด Timer
    }
  }

  Future<void> reloadTokens() async {
    if (_mutex.value) return; // ป้องกันคำขอซ้อน
    _mutex.value = true; // ล็อก mutex

    try {
      // อ่าน Token จาก Storage
      final access = await _storage.read(key: 'accessToken');
      final refresh = await _storage.read(key: 'refreshToken');

      if (access == null || refresh == null) {
        print('No tokens found. Skipping refresh.');
        accessToken.value = null;
        refreshToken.value = null;
        Get.snackbar('Error', 'No tokens found. Skipping refresh.');
        return;
      }

      refreshToken.value = refresh; // ตั้งค่า refresh token ชั่วคราว

      // ส่งคำขอเพื่ออัปเดต Token
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/user/refresh-token'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh_token': refresh}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final tokenData = data['data'];

        if (tokenData != null &&
            tokenData['access_token'] != null &&
            tokenData['refresh_token'] != null) {
          // บันทึก Token ใหม่ลง Storage
          await saveTokens(
              tokenData['access_token'], tokenData['refresh_token']);
          print('Tokens refreshed and saved successfully.');
          Get.snackbar('Success', 'Tokens refreshed successfully.');
        } else {
          print('Invalid token data in response: $tokenData');
          Get.snackbar(
              'Error', 'Invalid token data received from server.: $tokenData');
        }
      } else if (response.statusCode == 401) {
        print('Invalid token detected. Clearing tokens.');
        await deleteTokens(); // ลบ token ที่ใช้งานไม่ได้
        Get.snackbar('Error', 'Token is invalid. Please log in again.');
      } else {
        print('Failed to refresh tokens: ${response.statusCode}');
        print('Response body: ${utf8.decode(response.bodyBytes)}');
        Get.snackbar('Error', utf8.decode(response.bodyBytes));
      }
    } catch (e) {
      print('Error during token refresh: $e');
      Get.snackbar('Error', 'Error during token refresh: $e');
    } finally {
      _mutex.value = false; // ปลดล็อก mutex
    }
  }

  Future<void> saveTokens(String newAccessToken, String newRefreshToken) async {
    try {
      // อ่าน Token เดิมจาก Storage
      final currentAccessToken = await _storage.read(key: 'accessToken');
      final currentRefreshToken = await _storage.read(key: 'refreshToken');

      // ตรวจสอบว่า Token ตัวใหม่เหมือนกับตัวเก่าหรือไม่
      if (currentAccessToken == newAccessToken &&
          currentRefreshToken == newRefreshToken) {
        print('Tokens are the same as existing tokens. Skipping save.');
        Get.snackbar('Info', 'Tokens are already up-to-date.');
      }

      // บันทึก Token ใหม่
      await _storage.write(key: 'accessToken', value: newAccessToken);
      await _storage.write(key: 'refreshToken', value: newRefreshToken);

      // ตั้งค่า Token ในหน่วยความจำ
      accessToken.value = newAccessToken;
      refreshToken.value = newRefreshToken;

      print('Tokens saved: Access: $newAccessToken, Refresh: $newRefreshToken');

      // เริ่ม Timer ใหม่หลังจากบันทึกสำเร็จ
      restartTokenRefresh();
    } catch (e) {
      print('Error saving tokens: $e');
    }
  }

  Future<void> deleteTokens() async {
    await _storage.delete(key: 'accessToken');
    await _storage.delete(key: 'refreshToken');
    await Future.delayed(Duration(milliseconds: 100));
    accessToken.value = await _storage.read(key: 'accessToken');
    refreshToken.value = await _storage.read(key: 'refreshToken');
    print('accessToken after deletion: ${accessToken.value}');
    print('refreshToken after deletion: ${refreshToken.value}');
  }

  void startTokenRefresh() {
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      reloadTokens(); // เรียกใช้ loadTokens ทุก 30 วินาที
    });
    print('Token refresh started. (Every 30 seconds)');
  }

  void stopTokenRefresh() {
    _timer?.cancel();
    _timer = null;
    print('Token refresh stopped.');
  }

  void restartTokenRefresh() {
    stopTokenRefresh(); // หยุด Timer ปัจจุบัน
    startTokenRefresh(); // เริ่ม Timer ใหม่
  }
}
