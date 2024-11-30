import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/model/post_detail_model.dart';

class PostDetailController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var postDetail = Rxn<PostDetail>();
  var isLoading = false.obs;

  Future<bool> fetchPostDetail(String postId) async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading(false);
        return false;
      }
      final token = tokenController.accessToken.value;
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/posts/$postId'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
        },
      );
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print('Fetched JSON data: $jsonData');
        var postData = jsonData['data'];
        postDetail.value = PostDetail.fromJson(postData);
        isLoading(false);
        return true;
      } else {
        Get.snackbar(
            'Error', 'Failed to load post detail: ${response.reasonPhrase}');
        isLoading(false);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
      isLoading(false);
      return false;
    }
  }
}
