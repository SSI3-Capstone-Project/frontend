import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/model/offer_detail_model.dart';

class PostOfferDetailController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var offerDetail = Rxn<OfferDetail>();
  var isLoading = false.obs;

  Future<bool> fetchOfferDetail(String postId, String offerId) async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading(false);
        return false;
      }
      final token = tokenController.accessToken.value;
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/posts/$postId/offers/$offerId'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
        },
      );
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${utf8.decode(response.bodyBytes)}');
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        var offerData = jsonData['data'];
        offerDetail.value = OfferDetail.fromJson(offerData);
        isLoading(false);
        return true;
      } else {
        Get.snackbar(
          'Error',
          'Failed to load offer detail: ${response.reasonPhrase}',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading(false);
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()} in PostOfferDetailController',
        backgroundColor: Colors.grey.shade200,
      );
      isLoading(false);
      return false;
    }
  }

  Future<void> deleteOfferInPost(String postId, String offerId) async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading(false);
        return;
      }
      final token = tokenController.accessToken.value;
      final response = await http.patch(
        Uri.parse('${dotenv.env['API_URL']}/posts/$postId/offers/$offerId'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
        },
      );
      if (response.statusCode == 200) {
        // Ensure decoding with UTF-8
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print(jsonData.toString());
        Get.snackbar(
          'สำเร็จ',
          'ลบข้อเสนอดังกล่าวออกจากโพสต์แล้ว',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading(false);
      } else if (response.statusCode == 403) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print(jsonData.toString());
        Get.snackbar(
          'แจ้งเตือน',
          'คุณไม่มีสิทธิในการลบข้อเสนอดังกล่าวออกจากโพสต์',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading(false);
      } else {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print(jsonData.toString());
        Get.snackbar(
          'แจ้งเตือน',
          'เกิดข้อผิดพลาดในการลบข้อเสนอดังกล่าวออกจากโพสต์',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading(false);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()} in PostOfferDetailController',
        backgroundColor: Colors.grey.shade200,
      );
      isLoading(false);
    } finally {
      isLoading(false);
    }
  }
}
