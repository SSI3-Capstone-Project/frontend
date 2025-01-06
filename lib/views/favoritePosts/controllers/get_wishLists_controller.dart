import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/favoritePosts/models/wishLists_get_model.dart';

class GetWishListsController extends GetxController {
  final tokenController = Get.find<TokenController>();

  var wishLists = <WishListModel>[].obs;
  var isLoading = false.obs;

  Future<void> getWishLists(String userId) async {
    isLoading.value = true;
    Get.snackbar("UserID", userId);

    try {
      if (tokenController.accessToken.value == null) {
        isLoading.value = false;
        Get.snackbar('Error', 'No access token');
        return;
      }

      final token = tokenController.accessToken.value;
      final apiUrl = '${dotenv.env['API_URL']}/wishlists/$userId';
      print("API URL: $apiUrl");

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
        },
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(utf8.decode(response.bodyBytes));

        // ตรวจสอบประเภทของ data
        if (data is List) {
          wishLists.value = data.map((e) => WishListModel.fromJson(e)).toList();
        } else {
          Get.snackbar('Error', 'Unexpected data format: Not a List');
          print("Unexpected data format: $data");
        }
      } else {
        Get.snackbar(
            'Error', 'Failed to load wish lists: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
      print("Error: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
