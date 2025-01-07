import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';

class DeleteWishlistController {
  final tokenController = Get.find<TokenController>();
  var isLoading = false.obs;

  Future<bool> deleteWishList(String wishListId) async {
    isLoading.value = true;

    try {
      final token = tokenController.accessToken.value;

      var response = await http.delete(
        Uri.parse('${dotenv.env['API_URL']}/wishlists/$wishListId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        Get.snackbar("สำเร็จ", "ลบ wish list แล้ว");
        return true;
      } else {
        print('Error: ${response.statusCode}, Body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception occurred: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
