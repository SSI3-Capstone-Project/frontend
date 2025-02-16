import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/chat/models/chat_rooms_model.dart';

class ChatRoomController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var chatRoomList = <ChatRooms>[].obs;
  var isLoading = false.obs;

  Future<void> fetchChatRooms() async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading(false);
        return;
      }
      final token = tokenController.accessToken.value;
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/chatrooms/own'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
        },
      );
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print('---------------------Debug chat room-------------------------');
        print(jsonData.toString());
        if (jsonData['status'] == 200) {
          var chatRoomData = jsonData['data'];
          if (chatRoomData != null &&
              chatRoomData is List &&
              chatRoomData.isNotEmpty) {
            chatRoomList.value =
                chatRoomData.map((item) => ChatRooms.fromJson(item)).toList();
            isLoading(false);
          } else {
            chatRoomList.clear();
            Get.snackbar('แจ้งเตือน', 'ยังไม่แชทสำหรับสนทนา');
            isLoading(false);
          }
        } else {
          Get.snackbar('แจ้งเตือน', 'ไม่สามารถดึงข้อมูลห้องแชท');
          isLoading(false);
        }
      }
    } catch (e) {
      Get.snackbar(
          'Error', 'An error occurred: ${e.toString()} in ChatRoomController');
      isLoading(false);
    }
  }
}
