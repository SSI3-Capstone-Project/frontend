import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/model/offer_detail_model.dart';

class OfferDetailController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var offerDetail = Rxn<OfferDetail>();
  var isLoading = false.obs;

  Future<bool> fetchOfferDetail(String offerId) async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading(false);
        return false;
      }
      final token = tokenController.accessToken.value;
      isLoading(true);
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/offers/$offerId'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
        },
      );
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        var offerData = jsonData['data'];
        offerDetail.value = OfferDetail.fromJson(offerData);
        isLoading(false);
        return true;
      } else {
        Get.snackbar(
            'Error', 'Failed to load offer detail: ${response.reasonPhrase}');
        isLoading(false);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
      isLoading(false);
      return false;
    }
  }
}
