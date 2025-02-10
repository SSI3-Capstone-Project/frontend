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

  Future<void> getWishLists() async {
    if (tokenController.accessToken.value == null || tokenController.accessToken.value!.isEmpty) {
      Get.snackbar('Error', 'No access token');
      return;
    }

    isLoading.value = true;

    try {
      final token = tokenController.accessToken.value!;
      final apiUrl = '${dotenv.env['API_URL']}/wishlists';

      print("Fetching wish lists from: $apiUrl");

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes));

        if (decodedResponse is Map<String, dynamic> && decodedResponse.containsKey('data')) {
          var dataList = decodedResponse['data'];

          if (dataList is List) {
            wishLists.assignAll(dataList.map((e) => WishListModel.fromJson(e)).toList());
          } else {
            Get.snackbar('Error', 'Unexpected data format');
          }
        } else {
          Get.snackbar('Error', 'Response does not contain expected data key');
        }
      } else {
        Get.snackbar('Error', 'Failed to load wish lists: ${response.statusCode}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
      print("Error in GetWishListsController: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
