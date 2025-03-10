import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/profile/models/other_user_profile_model.dart';

class OtherUserProfileController extends GetxController {
  final tokenController = Get.find<TokenController>();

  var userProfile = Rxn<OtherUserProfile>();
  var isLoading = false.obs;

  Future<void> fetchOtherUserProfile(String userId) async {
    isLoading.value = true;

    try {
      if (tokenController.accessToken.value == null) {
        // ถ้าไม่มี token ไม่ต้องโหลดข้อมูล
        isLoading.value = false;
        return;
      }
      final token = tokenController.accessToken.value;
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final utf8Data = utf8.decode(response.bodyBytes);
        final data = json.decode(utf8Data)['data'];
        userProfile.value = OtherUserProfile.fromJson(data);

        print("ข้อมูลโปรไฟล์ของผู้ใช้ท่านอื่น: ${userProfile.value}");
        isLoading.value = false;
      } else {
        Get.snackbar('Error', 'ไม่สามารถดึงข้อมูลโปรไฟล์ของผู้ใช้ได้');
        print("ดึงข้อมูลโปรไฟล์ของผู้ใช้ท่านอื่นล้มเหลว");
        isLoading.value = false;
      }
    } catch (e) {
      Get.snackbar('Error', 'เกิดข้อผิดพลาด: $e ใน OtherUserProfileController');
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }
}
