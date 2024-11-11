import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/model/posts_model.dart';

class PostsController extends GetxController {
  var postList = <Posts>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/posts'),
      );
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        var postData = jsonData['data'];
        if (postData != null && postData is List && postData.isNotEmpty) {
          postList.value =
              postData.map((item) => Posts.fromJson(item)).toList();
        } else {
          postList.clear(); // Clear the list if no data is present
          Get.snackbar('Notice', 'No posts available.');
        }
      } else {
        Get.snackbar('Error', 'Failed to load posts: ${response.reasonPhrase}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
}
