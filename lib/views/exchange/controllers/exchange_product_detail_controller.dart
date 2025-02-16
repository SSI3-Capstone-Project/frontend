import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/exchange/models/post_detail_model.dart';
import 'package:mbea_ssi3_front/views/exchange/models/offer_detail_model.dart';

class ExchangeProductDetailController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var postDetail = Rxn<PostDetail>();
  var offerDetail = Rxn<OfferDetail>();
  var isLoading = false.obs;

  Future<bool> fetchPostAndOfferDetail(String postID, String offerID) async {
    try {
      print(
          '--------------------------post offer id--------------------------------');
      print(postID);
      print(offerID);
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading(false);
        return false;
      }
      final token = tokenController.accessToken.value;
      final response = await http.get(
        Uri.parse(
            '${dotenv.env['API_URL']}/posts/$postID/offers/$offerID/details'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        var productData = jsonData['data'];
        postDetail.value = PostDetail.fromJson(productData);
        offerDetail.value = OfferDetail.fromJson(productData);
        isLoading(false);
        return true;
      } else {
        Get.snackbar('Error',
            'Failed to load post and offer detail: ${response.reasonPhrase}');
        isLoading(false);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error',
          'An error occurred: ${e.toString()} in ExchangeProductDetailController');
      isLoading(false);
      return false;
    }
  }
}
