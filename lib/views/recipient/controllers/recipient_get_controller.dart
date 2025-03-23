import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../controller/token_controller.dart';
import '../models/recipient_get_model.dart';

class RecipientController extends GetxController {
  final tokenController = Get.find<TokenController>();

  var recipient = Rxn<Recipient>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRecipient();
  }

  Future<void> fetchRecipient() async {
    isLoading.value = true;

    try {
      if (tokenController.accessToken.value == null) {
        isLoading.value = false;
        return;
      }
      final token = tokenController.accessToken.value;
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/user/recipient'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final utf8Data = utf8.decode(response.bodyBytes);
        final decodedJson = json.decode(utf8Data);
        recipient.value = Recipient.fromJson(decodedJson);
      } else {
        Get.snackbar('Error', 'Failed to fetch recipient details');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e in RecipientController');
    } finally {
      isLoading.value = false;
    }
  }
}
