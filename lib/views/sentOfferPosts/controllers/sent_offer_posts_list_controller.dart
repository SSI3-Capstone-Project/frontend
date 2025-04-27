import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import '../models/sent_offer_posts_list_model.dart';

class SentOfferPostsListController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var sentOfferPosts = <GetSentOfferPostList>[].obs;
  var isLoading = false.obs;

  Future<void> fetchSentOfferPosts(String offerId, {String? postTitle}) async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        return;
      }

      final token = tokenController.accessToken.value;

      // สร้าง URI โดยเช็คว่ามี postTitle หรือไม่
      final uri = Uri.parse('${dotenv.env['API_URL']}/offers/$offerId/posts')
          .replace(
              queryParameters: postTitle != null && postTitle.isNotEmpty
                  ? {'post_title': postTitle}
                  : null);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        var responseData = GetSentOfferPostListResponse.fromJson(jsonData);
        sentOfferPosts.value = responseData.data;
      } else {
        Get.snackbar(
          'Error',
          'Failed to load sent offer posts',
          backgroundColor: Colors.grey.shade200,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred while fetching sent offer posts',
        backgroundColor: Colors.grey.shade200,
      );
    } finally {
      isLoading(false);
    }
  }
}
