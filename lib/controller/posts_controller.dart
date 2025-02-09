import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/model/posts_model.dart';

class PostsController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var postList = <Posts>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading(false);
        return;
      }
      final token = tokenController.accessToken.value;
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/posts/own'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
        },
      );
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        var postData = jsonData['data'];
        if (postData != null && postData is List && postData.isNotEmpty) {
          postList.value =
              postData.map((item) => Posts.fromJson(item)).toList();
          isLoading(false);
        } else {
          postList.clear(); // Clear the list if no data is present
          Get.snackbar('แจ้งเตือน', 'สร้างโพสต์ของคุณ เพื่อเริ่มการแลกเปลี่ยน');
          isLoading(false);
        }
      } else {
        Get.snackbar('Error', 'Failed to load posts: ${response.reasonPhrase}');
        isLoading(false);
      }
    } catch (e) {
      Get.snackbar(
          'Error', 'An error occurred: ${e.toString()} in PostsController');
      isLoading(false);
    } finally {
      isLoading(false);
    }
  }
}
