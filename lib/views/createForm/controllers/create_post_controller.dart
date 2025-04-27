import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/createForm/models/create_post_model.dart';
import 'package:http_parser/http_parser.dart';

class CreatePostController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var isLoading = false.obs;

  Future<bool> createPost(Post post) async {
    isLoading.value = true;
    if (tokenController.accessToken.value == null) {
      // Get.snackbar('Error', 'No access token found.');
      isLoading.value = false;
      return false;
    }
    final token = tokenController.accessToken.value;
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${dotenv.env['API_URL']}/posts'), // เปลี่ยน URL ตามจริง
    );

    // แนบ accessToken ลงบน header ของ MultipartRequest
    request.headers['Authorization'] = 'Bearer $token';

    // เพิ่มข้อมูลฟอร์มที่ไม่ใช่ไฟล์
    request.fields.addAll(
        post.toJson().map((key, value) => MapEntry(key, value.toString())));

    // เพิ่มไฟล์สื่อ
    for (var file in post.mediaFiles) {
      String mimeType = file.path.endsWith('.mp4')
          ? 'video/mp4'
          : 'image/png'; // กำหนด MIME type สำหรับไฟล์รูปภาพ

      request.files.add(
        await http.MultipartFile.fromPath(
          file.path.endsWith('.mp4') ? 'video_files' : 'image_files',
          file.path,
          contentType: MediaType.parse(mimeType), // กำหนดประเภท MIME
        ),
      );
    }

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        // Handle success
        print('Post created successfully: $responseData');
        isLoading.value = false;
        return true;
      } else {
        // อ่านและแสดงรายละเอียดข้อผิดพลาด
        var errorData = await response.stream.bytesToString();
        print(
            'Failed to create post: ${response.statusCode}, Error: $errorData');
        Get.snackbar(
          'แจ้งเตือน',
          'เกิดข้อผิดพลาดไม่สามารถสร้างโพสต์ได้',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      // Handle exception
      print('Error: $e');
      isLoading.value = false;
      return false;
    }
  }
}
