import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/model/post_detail_model.dart';

class PostDetailController extends GetxController {
  var postDetail = Rxn<PostDetail>();
  var isLoading = false.obs;

  Future<void> fetchPostDetail(String postId) async {
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/post/$postId'),
      );
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print('Fetched JSON data: $jsonData');
        var postData = jsonData['data'];
        postDetail.value = PostDetail.fromJson(postData);
      } else {
        Get.snackbar(
            'Error', 'Failed to load post detail: ${response.reasonPhrase}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
}
