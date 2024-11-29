import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/createForm/models/create_offer_model.dart';
import 'package:http_parser/http_parser.dart';

class CreateOfferController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var isLoading = false.obs;

  // จำเป็นต้องตั้ง accessToken ที่ได้รับจากการ login หรืออื่นๆ
  String? accessToken;

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    accessToken = tokenController.accessToken.value;
  }

  Future<String?> createOffer(Offer offer) async {
    await tokenController.loadTokens();
    final token = tokenController.accessToken.value;
    isLoading.value = true;
    if (accessToken == null) {
      Get.snackbar('Error', 'No access token found.');
      isLoading.value = false;
      return null;
    }
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${dotenv.env['API_URL']}/offers'), // เปลี่ยน URL ตามจริง
    );

    // แนบ accessToken ลงบน header ของ MultipartRequest
    request.headers['Authorization'] = 'Bearer $token';

    // เพิ่มข้อมูลฟอร์มที่ไม่ใช่ไฟล์
    request.fields.addAll(
        offer.toJson().map((key, value) => MapEntry(key, value.toString())));

    // เพิ่มไฟล์สื่อ
    for (var file in offer.mediaFiles) {
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
        var parsedResponse = jsonDecode(responseData);

        if (parsedResponse['data'] != null &&
            parsedResponse['data']['id'] != null) {
          String offerId = parsedResponse['data']['id'];
          print('Offer created successfully with ID: $offerId');
          isLoading.value = false;
          return offerId;
        } else {
          print('Unexpected response structure: $responseData');
          Get.snackbar('แจ้งเตือน', 'ไม่พบ ID ของข้อเสนอในข้อมูลที่ตอบกลับ');
          isLoading.value = false;
          return null;
        }
      } else {
        // อ่านและแสดงรายละเอียดข้อผิดพลาด
        var errorData = await response.stream.bytesToString();
        print(
            'Failed to create offer: ${response.statusCode}, Error: $errorData');
        Get.snackbar('แจ้งเตือน', 'เกิดข้อผิดพลาดไม่สามารถสร้างข้อเสนอได้');
        isLoading.value = false;
        return null;
      }
    } catch (e) {
      // Handle exception
      print('Error: $e');
      isLoading.value = false;
      return null;
    }
  }
}
