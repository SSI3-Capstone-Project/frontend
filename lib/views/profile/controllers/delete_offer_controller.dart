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

  Future<bool> deleteOffer(String offerId) async {
    await tokenController.loadTokens();
    isLoading.value = true;
    if (accessToken == null) {
      Get.snackbar('Error', 'No access token found.');
      isLoading.value = false;
      return false;
    }
    try {
      final token = tokenController.accessToken.value;
      final response = await http.delete(
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
