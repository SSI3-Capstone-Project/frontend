import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'dart:convert';

class CardCreateController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var isLoading = false.obs;
  var tokenId = ''.obs;

  Future<bool> createCardToken({
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
      'Basic ${base64Encode(utf8.encode("pkey_test_630m532d4ot9rgjzyqa:"))}',
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

        if (tokenId.value.isNotEmpty) {
          Get.snackbar("Success", "Token created successfully: ${tokenId.value}");
          await createCreditCard(tokenId.value);
          return true;
        }
      } else {
        Get.snackbar("Error", "Failed to create token: ${response.body}");
        return false;
      }
    } catch (e) {
      Get.snackbar("Error", "An error occurred: $e");
    } finally {
      isLoading(false);
    }

    return false;
  }

  Future<bool> createCreditCard(String cardToken) async {
    isLoading.value = true;
    if (tokenController.accessToken.value == null) {
      isLoading.value = false;
      return false;
    }
    final token = tokenController.accessToken.value;
    final url = Uri.parse('${dotenv.env['API_URL']}/user/credit-cards');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = jsonEncode({
      'card_token': cardToken,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Credit card added successfully");
        isLoading.value = false;
        return true;
      } else {
        var errorData = response.body;
        print('Failed to add credit card: ${response.statusCode}, Error: $errorData');
        Get.snackbar("Error", "Failed to add credit card");
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      print('Error: $e');
      isLoading.value = false;
      return false;
    }
  }
}

