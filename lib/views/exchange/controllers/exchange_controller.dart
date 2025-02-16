import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'dart:convert';

import 'package:mbea_ssi3_front/views/exchange/models/exchange_model.dart';

class ExchangeController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var exchange = Rxn<ExchangeModel>();
  var isLoading = false.obs;

  Future<bool> fetchExchangeDetails(String exchangeId) async {
    try {
      exchange.value = null;
      isLoading.value = true;
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading(false);
        return false;
      }
      final token = tokenController.accessToken.value;
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/exchanges/$exchangeId'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        exchange.value = ExchangeModel.fromJson(jsonData['data']);
        isLoading.value = false;
        return true;
      } else {
        exchange.value = null;
        Get.snackbar('แจ้งเตือน', 'ไม่สามารถดึงรายละเอียดการแลกเปลี่ยนได้');
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      Get.snackbar(
          'Error', 'An error occurred: ${e.toString()} in ExchangeController');
      isLoading.value = false;
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
