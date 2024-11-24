import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/profile/models/profile_get_model.dart';

class UserProfileController extends GetxController {
  final tokenController = Get.find<TokenController>();
  String? accessToken;

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    accessToken = tokenController.accessToken.value;
    fetchUserProfile();
  }

  var userProfile = Rxn<UserProfile>();
  var isLoading = false.obs;

  Future<void> fetchUserProfile() async {
    isLoading.value = true;

    try {
      final token = tokenController.accessToken.value;
      if (accessToken == null) {
        Get.snackbar('Error', 'No access token found.');
        return;
      }
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/users/profile'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'];
        userProfile.value = UserProfile.fromJson(data);
        print("This is data of user profile: ${userProfile.value}");
      } else {
        Get.snackbar('Error', 'Failed to fetch user profile');
        print("failed to fetch user profile");
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
