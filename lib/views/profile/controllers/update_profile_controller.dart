import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/profile/controllers/get_profile_controller.dart';
import 'package:mbea_ssi3_front/views/profile/models/profile_update_model.dart';

class UpdateProfileController extends GetxController {
  var isLoading = false.obs;
  final userProfileController = Get.put(UserProfileController());

  Future<void> updateProfile(UpdateProfileRequest profileData) async {
    try {
      print(profileData.imageUrl);
      print(
          "This is data before updating profile: ${userProfileController.fetchUserProfile()}");
      // Get the token for Authorization
      final token = Get.find<TokenController>().accessToken.value;
      final Map<String, String> formData = {
        'username': profileData.username,
        'firstname': profileData.firstname,
        'lastname': profileData.lastname,
        'email': profileData.email,
        'phone': profileData.phone,
        'gender': profileData.gender,
      };

      // If there is an image, prepare it for upload
      if (profileData.imageUrl != null && profileData.imageUrl!.isNotEmpty) {
        final request = http.MultipartRequest(
          'PUT',
          Uri.parse('${dotenv.env['API_URL']}/user/profile'),
        );

        // Add authorization header
        request.headers['Authorization'] = 'Bearer $token';

        // Add other form fields
        formData.forEach((key, value) {
          request.fields[key] = value;
        });

        String mimeType =
            profileData.imageUrl!.endsWith('.png') ? 'png' : 'jpg';
        // Add the image file to the request
        final imageFile = await http.MultipartFile.fromPath(
            'image_file', profileData.imageUrl!,
            contentType: MediaType('image', mimeType));
        request.files.add(imageFile);

        // Send the request
        final response = await request.send();
        final responseData = await response.stream.bytesToString();

        // Check the response status
        if (response.statusCode == 200) {
          Get.snackbar('Success', 'Profile updated successfully.');
          print("user image not null");
          print(
              "This is data after updating profile: ${userProfileController.fetchUserProfile()}");
          print("userProfile value: ${profileData}");
        } else {
          print(
              '-----------------------------------------------------------------');
          print('Response: $responseData');
          Get.snackbar('Error', 'Failed to update profile.');
        }
      } else {
        // If no image, send the data without image file
        final response = await http.put(
          Uri.parse('${dotenv.env['API_URL']}/user/profile'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: formData,
        );

        // Handle the response
        if (response.statusCode == 200) {
          Get.snackbar('สำเร็จ', 'อัปเดตโปรไฟล์สำเร็จแล้ว');
          print(userProfileController.fetchUserProfile());
          print("userProfile value: ${profileData}");
        } else {
          print('------------------------------------------------------------');
          print('Failed to refresh tokens: ${response.statusCode}');
          print('Response body: ${utf8.decode(response.bodyBytes)}');
          Get.snackbar('Errorsss', response.body);
          print('------------------------------------------------------------');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e in UpdateProfileController');
    }
  }
}
