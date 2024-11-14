import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';

class OfferDeleteController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var isLoading = false.obs;

  // จำเป็นต้องตั้ง accessToken ที่ได้รับจากการ login หรืออื่นๆ
  String? accessToken;

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    accessToken = tokenController.accessToken.value;
  }

  Future<void> deleteOffer(String offerId) async {
    isLoading.value = true;
    if (accessToken == null) {
      Get.snackbar('Error', 'No access token found.');
      return;
    }
    try {
      final response = await http.delete(
        Uri.parse('${dotenv.env['API_URL']}/offer/$offerId'),
        headers: {
          'Authorization': 'Bearer $accessToken', // แนบ Bearer Token
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Offer deleted successfully');
      } else {
        Get.snackbar('Error', 'Failed to delete offer');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
