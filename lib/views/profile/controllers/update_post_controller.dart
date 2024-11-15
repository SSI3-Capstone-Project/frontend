import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'dart:convert';
// import 'dart:io';

import 'package:mbea_ssi3_front/views/profile/models/post_update_model.dart';

class UpdatePostController extends GetxController {
  final tokenController = Get.find<TokenController>();

  // จำเป็นต้องตั้ง accessToken ที่ได้รับจากการ login หรืออื่นๆ
  String? accessToken;

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    accessToken = tokenController.accessToken.value;
  }

  var updatedPost = UpdatePost(
    id: '',
    title: '',
    subCollectionId: '',
    description: '',
    flaw: null,
    desiredItem: '',
    postImages: [],
    postVideos: [],
    imageFiles: [],
    videoFiles: [],
  ).obs;

  Future<void> updatePostDetails(UpdatePost postToUpdate) async {
    print('--- Post Data to be Updated ---');
    print('ID: ${postToUpdate.id}');
    print('Title: ${postToUpdate.title}');
    print('Sub Collection ID: ${postToUpdate.subCollectionId}');
    print('Description: ${postToUpdate.description}');
    print('Flaw: ${postToUpdate.flaw}');
    print('Desired Item: ${postToUpdate.desiredItem}');
    print('Post Images: ${jsonEncode(postToUpdate.postImages)}');
    print('Post Videos: ${jsonEncode(postToUpdate.postVideos)}');
    print('Image Files:');
    for (var file in postToUpdate.imageFiles) {
      print(' - Path: ${file.path}');
    }
    print('Video Files:');
    for (var file in postToUpdate.videoFiles) {
      print(' - Path: ${file.path}');
    }
    print('-----------------------------');
    if (accessToken == null) {
      Get.snackbar('Error', 'No access token found.');
      return;
    }
    final request = http.MultipartRequest(
        'PUT', Uri.parse('${dotenv.env['API_URL']}/post/${postToUpdate.id}'));

    // แนบ accessToken ลงบน header ของ MultipartRequest
    request.headers['Authorization'] = 'Bearer $accessToken';

    // ตั้งค่า fields โดยไม่ต้องใช้ ?? ''
    request.fields['title'] = postToUpdate.title;
    request.fields['sub_collection_id'] = postToUpdate.subCollectionId;
    request.fields['description'] = postToUpdate.description;

    if (postToUpdate.flaw != null) {
      request.fields['flaw'] = postToUpdate.flaw!;
    }

    request.fields['desired_item'] = postToUpdate.desiredItem;
    request.fields['post_images'] = jsonEncode(postToUpdate.postImages);
    request.fields['post_videos'] = jsonEncode(postToUpdate.postVideos);

    for (var file in postToUpdate.imageFiles) {
      if (file.path.isNotEmpty) {
        String mimeType = file.path.endsWith('.png') ? 'png' : 'jpeg';
        request.files.add(
          await http.MultipartFile.fromPath(
            'image_files',
            file.path,
            contentType: MediaType('image', mimeType),
          ),
        );
      }
    }

    for (var file in postToUpdate.videoFiles) {
      if (file.path.isNotEmpty) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'video_files',
            file.path,
            contentType: MediaType('video', 'mp4'),
          ),
        );
      }
    }

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseData);

        // ตรวจสอบว่ามีฟิลด์ 'data' อยู่ใน jsonResponse และไม่ใช่ null
        if (jsonResponse != null && jsonResponse['data'] != null) {
          updatedPost.value = UpdatePost.fromJson(jsonResponse['data']);
          print('Post updated successfully.');
        } else {
          print('Response data is missing or null.');
        }
      } else {
        print('Failed to update post. Status code: ${response.statusCode}');
        print('Response: $responseData');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }
}
