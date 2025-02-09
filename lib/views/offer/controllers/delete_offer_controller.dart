import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';

class OfferDeleteController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var isLoading = false.obs;

  Future<bool> deleteOffer(String offerId) async {
    try {
      isLoading.value = true;
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading.value = false;
        return false;
      }
      final token = tokenController.accessToken.value;
      final response = await http.patch(
        Uri.parse('${dotenv.env['API_URL']}/offers/$offerId'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
        },
      );

      if (response.statusCode == 200) {
        Get.snackbar('สำเร็จ', 'ข้อเสนอได้ถูกลบออกไปแล้ว');
        isLoading.value = false;
        return true;
      } else {
        Get.snackbar('แจ้งเตือน', 'เกิดข้อผิดพลาดในการลบข้อเสนอ');
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      Get.snackbar('แจ้งเตือน', 'เกิดข้อผิดพลาด: $e');
      isLoading.value = false;
      return false;
    }
  }
}
