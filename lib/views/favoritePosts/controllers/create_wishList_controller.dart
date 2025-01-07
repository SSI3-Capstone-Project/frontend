import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/favoritePosts/models/wishList_create_model.dart'; // Import WishList model

class CreateWishListController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var isLoading = false.obs;

  Future<WishListDetail> createWishList(String userId, String postId) async {
    isLoading.value = true;

    try {
      final token = tokenController.accessToken.value;

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${dotenv.env['API_URL']}/wishlist/$userId/$postId'),
      );

      request.headers['Authorization'] = 'Bearer $token';

      var response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        var responseBody = await response.stream.bytesToString();
        var jsonData = json.decode(responseBody);

        WishListDetail wishList = WishListDetail.fromJson(
            jsonData['wish_list_detail']); // อ้างอิงฟิลด์ที่ถูกต้อง

        Get.snackbar("สำเร็จ", "สร้าง wish list แล้ว");
        return wishList;
      } else {
        var responseBody = await response.stream.bytesToString();
        print('Error: ${response.statusCode}, Body: $responseBody');
        throw Exception('Failed to create wish list: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      // สร้าง WishListDetail default เพื่อลดผลกระทบจากข้อผิดพลาด
      return WishListDetail(
        wishListId: "unknown",
        postId: postId,
        userId: userId,
        status: "error",
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
