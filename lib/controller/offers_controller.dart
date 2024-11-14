import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/model/offers_model.dart';

class OffersController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var offerList = <Offers>[].obs;
  var isLoading = false.obs;

  // จำเป็นต้องตั้ง accessToken ที่ได้รับจากการ login หรืออื่นๆ
  String? accessToken;

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    accessToken = tokenController.accessToken.value;
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    try {
      isLoading(true);
      if (accessToken == null) {
        Get.snackbar('Error', 'No access token found.');
        return;
      }
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/offers'),
        headers: {
          'Authorization': 'Bearer $accessToken', // แนบ Bearer Token
        },
      );
      if (response.statusCode == 200) {
        // Ensure decoding with UTF-8
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        var offerData = jsonData['data'];
        if (offerData != null && offerData is List && offerData.isNotEmpty) {
          offerList.value =
              offerData.map((item) => Offers.fromJson(item)).toList();
        } else {
          offerList.clear(); // Clear the list if no data is present
          Get.snackbar('Notice', 'No offers available.');
        }
      } else {
        Get.snackbar(
            'Error', 'Failed to load offers: ${response.reasonPhrase}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
}
