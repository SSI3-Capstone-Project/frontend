import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/model/offers_model.dart';
import 'package:mbea_ssi3_front/views/post/models/post_offer_model.dart';

class PostOfferController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var offerList = <PostOffers>[].obs;
  var isLoading = false.obs;

  Future<void> fetchOffers(String postId) async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading(false);
        return;
      }
      final token = tokenController.accessToken.value;
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/posts/${postId}'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
        },
      );
      if (response.statusCode == 200) {
        // Ensure decoding with UTF-8
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        var offerData = jsonData['data']?['offers'];
        if (offerData != null && offerData is List && offerData.isNotEmpty) {
          offerList.value =
              offerData.map((item) => PostOffers.fromJson(item)).toList();
          isLoading(false);
        } else {
          offerList.clear(); // Clear the list if no data is present
          // Get.snackbar('แจ้งเตือน', 'ยังไม่พบข้อเสนอถูกที่ถูกยื่นมา');
          isLoading(false);
        }
      } else {
        Get.snackbar(
            'Error', 'Failed to load offers: ${response.reasonPhrase}');
        isLoading(false);
      }
    } catch (e) {
      Get.snackbar(
          'Error', 'An error occurred: ${e.toString()} in PostOfferController');
      isLoading(false);
    } finally {
      isLoading(false);
    }
  }
}
