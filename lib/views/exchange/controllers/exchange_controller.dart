import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExchangeController extends GetxController {
  var isLoading = false.obs;
  var successMessage = ''.obs;
  var errorMessage = ''.obs;

  Future<void> createExchange({
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
      isLoading.value = true;

      final url = Uri.parse('http://localhost:8080/api/exchanges');
      final token = "YOUR_BEARER_TOKEN"; // เปลี่ยนเป็น token จริง

      final body = jsonEncode({
        "post_id": postId,
        "offer_id": offerId,
        "exchange_type": exchangeType,
        "post_price_diff": postPriceDiff,
        "offer_price_diff": offerPriceDiff,
        "meeting_point": {
          "latitude": latitude,
          "longitude": longitude,
          "location": location
        },
        "scheduled_time": scheduledTime
      });

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      if (response.statusCode == 201) {
        successMessage.value = "Exchange created successfully!";
      } else {
        errorMessage.value = "Failed to create exchange: ${response.body}";
      }
    } catch (e) {
      errorMessage.value = "Error: $e";
    } finally {
      isLoading.value = false;
    }
  }
}
