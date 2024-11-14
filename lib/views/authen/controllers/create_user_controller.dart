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
  Future<void> registerUser(String imagePath) async {
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
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        var jsonResponse = json.decode(responseData);
        userRequest.value = CreateUserRequest.fromJson(jsonResponse['data']);
        isLoading.value = false;
        Get.snackbar('สำเร็จ', 'ลงทะเบียนผู้ใช้เรียบร้อยแล้ว');
      } else if (response.statusCode == 500) {
        Get.snackbar('ข้อผิดพลาด', 'ชื่อผู้ใช้นี้ถูกลงทะเบียนไปแล้ว');
      } else {
        var errorData = await response.stream.bytesToString();
        print(
            'Failed to create post: ${response.statusCode}, Error: $errorData');
        Get.snackbar('Error', 'Failed to register user');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred');
    } finally {
      isLoading.value = false;
    }
  }
}
