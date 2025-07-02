import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/profile/models/profile_get_model.dart';

class UserProfileController extends GetxController {
  final tokenController = Get.find<TokenController>();

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    fetchUserProfile();
  }

  var userProfile = Rxn<UserProfile>();
  var isLoading = false.obs;

  Future<void> fetchUserProfile() async {
    isLoading.value = true;

    try {
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading.value = false;
        return;
      }
      final token = tokenController.accessToken.value;
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/user/profile'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
        },
      );

      if (response.statusCode == 200) {
        final utf8Data = utf8.decode(response.bodyBytes);
        final data = json.decode(utf8Data)['data'];
        userProfile.value = UserProfile.fromJson(data);

        print("This is data of user profile: ${userProfile.value}");
        isLoading.value = false;
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch user profile',
          backgroundColor: Colors.grey.shade200,
        );
        print("failed to fetch user profile");
        isLoading.value = false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e in UserProfileController',
        backgroundColor: Colors.grey.shade200,
      );
      isLoading.value = false;
    } finally {
      isLoading.value = false;
    }
  }
}
