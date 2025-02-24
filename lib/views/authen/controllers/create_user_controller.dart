import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

import 'package:mbea_ssi3_front/views/authen/models/create_user_model.dart';

class UserCreationController extends GetxController {
  var userRequest = CreateUserRequest(
    username: '',
    firstname: '',
    lastname: '',
    email: '',
    phone: '',
    gender: '',
  ).obs;

  // Loading status to show loading indicators
  var isLoading = false.obs;

  // Register User method
  Future<bool> registerUser(String imagePath) async {
    isLoading.value = true;

    var uri = Uri.parse('${dotenv.env['API_URL']}/user/registration');
    var request = http.MultipartRequest('POST', uri)
      ..fields['username'] = userRequest.value.username
      ..fields['password'] = userRequest.value.password ?? ''
      ..fields['firstname'] = userRequest.value.firstname
      ..fields['lastname'] = userRequest.value.lastname
      ..fields['email'] = userRequest.value.email
      ..fields['phone'] = userRequest.value.phone
      ..fields['gender'] = userRequest.value.gender;

    // Attach image file if provided
    if (imagePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'image_file',
        imagePath,
        contentType:
            MediaType('image', 'jpeg'), // กำหนดประเภทไฟล์เป็น image/jpeg
      ));
    } else {
      // Load the default asset image
      ByteData byteData =
          await rootBundle.load('assets/images/white_gray_person_image.png');
      List<int> imageData = byteData.buffer.asUint8List();

      request.files.add(http.MultipartFile.fromBytes(
        'image_file',
        imageData,
        filename: 'default_image.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        userRequest.value = CreateUserRequest.fromJson(jsonResponse['data']);
        Get.snackbar('สำเร็จ', 'ลงทะเบียนผู้ใช้เรียบร้อยแล้ว');
        isLoading.value = false;
        return true;
      } else if (response.statusCode == 409) {
        var errorData = await response.stream.bytesToString();
        var errorJson = json.decode(errorData);

        // แปลงข้อความข้อผิดพลาดเป็นภาษาไทย
        var errorMessages = (errorJson['errors'] as List).map((e) {
          switch (e['field']) {
            case 'Username':
              return 'ชื่อผู้ใช้นี้ถูกใช้ไปแล้ว';
            case 'Email':
              return 'อีเมลนี้ถูกใช้ไปแล้ว';
            case 'Phone':
              return 'เบอร์โทรนี้ถูกใช้ไปแล้ว';
            default:
              return e['error']; // หากไม่มีคำแปล ให้ใช้ข้อความเดิม
          }
        }).join(', '); // รวมข้อความทั้งหมดเข้าด้วยกัน

        Get.snackbar('แจ้งเตือน', errorMessages);
        print(errorMessages); // Debug log
        isLoading.value = false;
        return false;
      } else if (response.statusCode == 500) {
        Get.snackbar('แจ้งเตือน', 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์ (500)');
        isLoading.value = false;
        return false;
      } else {
        var errorData = await response.stream.bytesToString();

        Get.snackbar('แจ้งเตือน', errorData);
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      print(
          '-----------------------------------------------------------------');
      print(e);
      Get.snackbar('Error', 'An error occurred');
      isLoading.value = false;
      return false;
    }
  }
}
