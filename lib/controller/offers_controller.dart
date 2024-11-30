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

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    fetchOffers();
  }

  Future<void> fetchOffers() async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading(false);
        return;
      }
      final token = tokenController.accessToken.value;
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/offers'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
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
          Get.snackbar(
              'แจ้งเตือน', 'สร้างข้อเสนอของคุณ เพื่อยืนให้กับโพสต์ที่สนใจ');
        }
        isLoading(false);
      } else {
        print('adsadasdasdasdasdasdasd');
        Get.snackbar(
            'Error', 'Failed to load offers: ${response.reasonPhrase}');
        isLoading(false);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
      isLoading(false);
    } finally {
      isLoading(false);
    }
  }
}
