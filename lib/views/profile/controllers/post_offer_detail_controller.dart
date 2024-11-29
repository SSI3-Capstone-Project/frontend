import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/model/offer_detail_model.dart';

class PostOfferDetailController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var offerDetail = Rxn<OfferDetail>();
  var isLoading = false.obs;

  // จำเป็นต้องตั้ง accessToken ที่ได้รับจากการ login หรืออื่นๆ
  String? accessToken;

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    accessToken = tokenController.accessToken.value;
  }

  Future<bool> fetchOfferDetail(String postId, String offerId) async {
    try {
      await tokenController.loadTokens();
      final token = tokenController.accessToken.value;
      isLoading(true);
      if (accessToken == null) {
        Get.snackbar('Error', 'No access token found.');
        isLoading(false);
        return false;
      }
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/posts/$postId/offer/$offerId'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
        },
      );
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${utf8.decode(response.bodyBytes)}');
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
