import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/model/offer_detail_model.dart';

class OfferDetailController extends GetxController {
  var offerDetail = Rxn<OfferDetail>();
  var isLoading = false.obs;

  Future<void> fetchOfferDetail(String offerId) async {
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/offer/$offerId'),
      );
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        var offerData = jsonData['data'];
        offerDetail.value = OfferDetail.fromJson(offerData);
      } else {
        Get.snackbar(
            'Error', 'Failed to load offer detail: ${response.reasonPhrase}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
}
