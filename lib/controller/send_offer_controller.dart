import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:http/http.dart' as http;

class SendOfferController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var isLoading = false.obs;
  var message = ''.obs;

  // จำเป็นต้องตั้ง accessToken ที่ได้รับจากการ login หรืออื่นๆ
  String? accessToken;

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    accessToken = tokenController.accessToken.value;
  }

  Future<bool> addOffer({
    required String postId,
    required String offerId,
  }) async {
    try {
      final token = tokenController.accessToken.value;
      isLoading.value = true;

      if (token == null) {
        Get.snackbar('Error', 'No access token found.');
        isLoading.value = false;
        return false;
      }

      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/posts/${postId}/offer'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
          'Content-Type': 'application/json', // ระบุ Content-Type เป็น JSON
        },
        body: json.encode({
          'offer_id': offerId,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(utf8.decode(response.bodyBytes));
        message.value =
            responseData['message'] ?? 'Offer added to post successfully';
        Get.snackbar('สำเร็จ', 'ข้อเสนอของคุณถูกส่งไปแล้ว');
        isLoading.value = false;
        return true;
      } else {
        final Map<String, dynamic> responseData =
            json.decode(utf8.decode(response.bodyBytes));
        message.value =
            responseData['message'] ?? 'Failed to add offer to post';
        print(responseData);
        Get.snackbar('แจ้งเตือน', 'เกินปัญหาระหว่างการส่งข้อเสนอของคุณ');
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      message.value = 'Error occurred: $e';
      Get.snackbar('แจ้งเตือน', message.value);
      isLoading.value = false;
      return false;
    }
  }
}
