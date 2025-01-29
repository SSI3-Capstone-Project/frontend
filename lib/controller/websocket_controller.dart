import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatController extends GetxController {
  late IOWebSocketChannel channel;
  var messages = <Map<String, dynamic>>[].obs; // เก็บข้อความในรูปแบบ List<Map>
  var rooms = <Map<String, dynamic>>[].obs; // เก็บห้องแชทในรูปแบบ List<Map>
  var isConnected = false.obs; // สถานะการเชื่อมต่อ WebSocket
  final tokenController = Get.find<TokenController>();

  // ฟังก์ชันเชื่อมต่อไปยังห้องแชท
  void connectToRoom(String roomId) {
    try {
      final token = tokenController.accessToken.value;
      final url = Uri.parse('ws://10.0.2.2:8080/ws/$roomId');
      print('---------------------------------------------------------------');
      print('Connecting to: $url');
      print('---------------------------------------------------------------');

      // ส่ง token ใน Header
      channel = IOWebSocketChannel.connect(
        url,
        headers: {
          'Authorization': 'Bearer $token', // ส่ง token ใน Header
        },
      );

      channel.stream.listen(
        (message) {
          print('Received: $message');
          // อัปเดตข้อความใน messages
          messages.add(jsonDecode(message));
        },
        onError: (error) {
          print('WebSocket Error: $error');
        },
        onDone: () {
          print('WebSocket connection closed.');
        },
      );

      isConnected.value = true; // อัปเดตสถานะการเชื่อมต่อ
    } catch (e) {
      print('Connection Error: $e');
      isConnected.value = false;
    }
  }

  // ฟังก์ชันส่งข้อความ
  Future<void> sendMessage(String message, String roomID) async {
    try {
      if (tokenController.accessToken.value == null) {
        return;
      }
      final token = tokenController.accessToken.value;
      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/chatrooms/$roomID/messages'),
        body: jsonEncode({"message": message}),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        var result = jsonData['data'];
        Get.snackbar('Success', '$result');
      } else {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print('Response: ${response.body}');

        Get.snackbar('Error', 'Failed to send message: ${jsonData}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
    }
    if (isConnected.value) {
      final payload = {
        'type': 'message',
        'message': message,
      };
      // ส่งข้อความผ่าน WebSocket
      channel.sink.add(jsonEncode(payload));
      print(messages);
    } else {
      print('WebSocket is not connected.');
    }
  }

  // ฟังก์ชันปิดการเชื่อมต่อ WebSocket
  @override
  Future<void> onClose() async {
    print('---------------------------------------------------------------');
    print('Close websocket connection ');
    print('---------------------------------------------------------------');
    if (isConnected.value) {
      channel.sink.close();
    }
    super.onClose();

    // try {
    //   if (tokenController.accessToken.value == null) {
    //     return;
    //   }
    //   final token = tokenController.accessToken.value;
    //   final response = await http.delete(
    //     Uri.parse(
    //         '${dotenv.env['API_URL']}/chatrooms/50f98d4a-3edf-4644-9893-5fc6fba37116/leave'),
    //     headers: {
    //       'Authorization': 'Bearer $token',
    //       'Content-Type': 'application/json',
    //     },
    //   );
    //   if (response.statusCode == 200) {
    //     var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
    //     var result = jsonData['data'];
    //     Get.snackbar('Success', 'Tooooooom');
    //   } else {
    //     var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
    //     print('Response: ${response.body}');

    //     Get.snackbar('Error', 'Failed to Tooooooom ${jsonData}');
    //   }
    // } catch (e) {
    //   Get.snackbar('Error', 'An error occurred: ${e.toString()}');
    // }
  }
}
