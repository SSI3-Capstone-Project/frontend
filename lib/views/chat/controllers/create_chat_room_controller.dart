import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';

class CreateChatRoomController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var isLoading = false.obs;

  Future createChatRoom(String postID, String offerID) async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading(false);
        return null;
      }
      final token = tokenController.accessToken.value;
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/chatrooms'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'post_id': postID,
          'offer_id': offerID,
        }),
      );
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        var result = jsonData['data'];
        print(
            '----------------------------------create here----------------------------------------------------');
        print(jsonData.toString());
        // Get.snackbar('สำเร็จ', jsonData.toString());
        Get.snackbar('สำเร็จ', 'ห้องสนทนาถูกสร้างขึ้นแล้ว');
        isLoading(false);
        return result['id'];
      } else if (response.statusCode == 409) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        var result = jsonData['data'];
        print(
            '----------------------------------create here 2----------------------------------------------------');
        print(jsonData.toString());
        // Get.snackbar('แจ้งเตือน', 'ห้องสนทนาพร้อมใช้งานแล้ว');
        isLoading(false);
        return result['id'];
        // result['id'];
      } else {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print(jsonData.toString());
        Get.snackbar('แจ้งเตือน', 'เกิดข้อผิดพลาดในการสร้างห้องสนทนา');
        isLoading(false);
        return null;
      }
    } catch (e) {
      Get.snackbar('Error',
          'An error occurred: ${e.toString()} in CreateChatRoomController');
      isLoading(false);
      return null;
    }
  }
}
