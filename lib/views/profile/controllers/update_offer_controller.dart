import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'dart:convert';
// import 'dart:io';

import 'package:mbea_ssi3_front/views/profile/models/offer_update_model.dart';

class UpdateOfferController extends GetxController {
  final tokenController = Get.find<TokenController>();

  var updatedOffer = UpdateOffer(
    id: '',
    title: '',
    subCollectionId: '',
    subDistrictId: '',
    description: '',
    flaw: null,
    offerImages: [],
    offerVideos: [],
    imageFiles: [],
    videoFiles: [],
  ).obs;

  Future<bool> updateOfferDetails(UpdateOffer offerToUpdate) async {
    if (tokenController.accessToken.value == null) {
      // Get.snackbar('Error', 'No access token found.');
      return false;
    }
    final token = tokenController.accessToken.value;
    print('--- Offer Data to be Updated ---');
    print('ID: ${offerToUpdate.id}');
    print('Title: ${offerToUpdate.title}');
    print('Sub Collection ID: ${offerToUpdate.subCollectionId}');
    print('Description: ${offerToUpdate.description}');
    print('Flaw: ${offerToUpdate.flaw}');
    print('offer Images: ${jsonEncode(offerToUpdate.offerImages)}');
    print('offer Videos: ${jsonEncode(offerToUpdate.offerVideos)}');
    print('Image Files:');
    for (var file in offerToUpdate.imageFiles) {
      print(' - Path: ${file.path}');
    }
    print('Video Files:');
    for (var file in offerToUpdate.videoFiles) {
      print(' - Path: ${file.path}');
    }
    print('-----------------------------');
    final request = http.MultipartRequest('PUT',
        Uri.parse('${dotenv.env['API_URL']}/offers/${offerToUpdate.id}'));

    // แนบ accessToken ลงบน header ของ MultipartRequest
    request.headers['Authorization'] = 'Bearer $token';

    // ตั้งค่า fields โดยไม่ต้องใช้ ?? ''
    request.fields['title'] = offerToUpdate.title;
    request.fields['sub_collection_id'] = offerToUpdate.subCollectionId;
    request.fields['sub_district_id'] = offerToUpdate.subDistrictId;
    request.fields['description'] = offerToUpdate.description;

    if (offerToUpdate.flaw != null) {
      request.fields['flaw'] = offerToUpdate.flaw!;
    }

    request.fields['offer_images'] = jsonEncode(offerToUpdate.offerImages);
    request.fields['offer_videos'] = jsonEncode(offerToUpdate.offerVideos);

    for (var file in offerToUpdate.imageFiles) {
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

    for (var file in offerToUpdate.videoFiles) {
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
          updatedOffer.value = UpdateOffer.fromJson(jsonResponse['data']);
          print('Offer updated successfully.');
        } else {
          print('Response data is missing or null.');
        }
        return true;
      } else {
        print('Failed to update offer. Status code: ${response.statusCode}');
        print('Response: $responseData');
        return false;
      }
    } catch (e) {
      print('Error occurred: $e');
      return true;
    }
  }
}
