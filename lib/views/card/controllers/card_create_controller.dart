import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CardCreateController extends GetxController {
  var isLoading = false.obs;
  var tokenId = ''.obs;

  Future<void> createCardToken({
    required String name,
    required String number,
    required String expirationMonth,
    required String expirationYear,
    required String city,
    required String postalCode,
    required String securityCode,
  }) async {
    isLoading(true);

    final url = Uri.parse('https://vault.omise.co/tokens');
    final headers = {
      'Authorization':
      'Basic ${base64Encode(utf8.encode("pkey_test_61coosryhy0p7etyh9c:"))}',
      'Content-Type': 'application/x-www-form-urlencoded',
    };

    final body = {
      'card[name]': name,
      'card[number]': number,
      'card[expiration_month]': expirationMonth,
      'card[expiration_year]': expirationYear,
      'card[city]': city,
      'card[postal_code]': postalCode,
      'card[security_code]': securityCode,
    };

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        tokenId.value = responseData['id'] ?? '';
        Get.snackbar("Success", "Token created successfully: ${tokenId.value}");
      } else {
        Get.snackbar("Error", "Failed to create token: ${response.body}");
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading(false);
    }
  }
}
