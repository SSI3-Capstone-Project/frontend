import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mbea_ssi3_front/controller/token_controller.dart';

class MeetUpExchangeController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var isLoading = false.obs;

  Future<dynamic> createExchange({
    required String postId,
    required String offerId,
    required String exchangeType,
    double? postPriceDiff,
    double? offerPriceDiff,
    required double latitude,
    required double longitude,
    required String location,
    required String scheduledTime,
  }) async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading(false);
        return null;
      }
      final token = tokenController.accessToken.value;

      final url = Uri.parse(
          '${dotenv.env['API_URL']}/exchanges'); // เปลี่ยนเป็น token จริง

      final body = jsonEncode({
        "post_id": postId,
        "offer_id": offerId,
        "exchange_type": exchangeType,
        "post_price_diff": postPriceDiff,
        "offer_price_diff": offerPriceDiff,
        "meeting_point": {
          "latitude": latitude,
          "longtitude": longitude,
          "location": location,
          "scheduled_time": scheduledTime
        },
      });

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      print(
          '---------------------------Debug Create--------------------------------');
      print(body.toString());

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print(jsonData);
        Get.snackbar('สำเร็จ', 'เสนอวันเวลาและสถานที่ให้อีกฝ่ายแล้ว');
        isLoading(false);
        return jsonData['data']['id'];
      } else {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print(jsonData['error']['message']);
        if (jsonData['error']['message'] == 'Post not found') {
          Get.snackbar('แจ้งเตือน', 'วันเวลาและสถานถูกเสนอไปให้อีกฝ่ายแล้ว');
        } else {
          var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
          Get.snackbar('Error',
              'ไม่สามารถเสนอวันเวลาและสถานที่ได้ ${response.statusCode}${jsonData}');
        }
        isLoading(false);
        return null;
      }
    } catch (e) {
      Get.snackbar(
          'Error', 'An error occurred: ${e.toString()} in ExchangeController');
      isLoading(false);
      return null;
    }
  }
}
