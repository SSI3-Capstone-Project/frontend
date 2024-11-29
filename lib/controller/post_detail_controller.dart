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

  // จำเป็นต้องตั้ง accessToken ที่ได้รับจากการ login หรืออื่นๆ
  String? accessToken;

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    accessToken = tokenController.accessToken.value;
  }

  Future<bool> fetchPostDetail(String postId) async {
    try {
      await tokenController.loadTokens();
      final token = tokenController.accessToken.value;
      isLoading(true);
      if (accessToken == null) {
        Get.snackbar('Error', 'No access token found.');
        isLoading(false);
        return false;
      }
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
