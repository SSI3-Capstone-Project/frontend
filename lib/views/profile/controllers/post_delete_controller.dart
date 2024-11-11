import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class PostDeleteController extends GetxController {
  var isLoading = false.obs;

  Future<void> deletePost(String postId) async {
    isLoading.value = true;
    try {
      final response = await http.delete(
        Uri.parse('${dotenv.env['API_URL']}/post/$postId'),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Post deleted successfully');
      } else {
        Get.snackbar('Error', 'Failed to delete post');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
