import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/chat/models/chat_room_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/views/chat/models/message_model.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

class ChatController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var isLoading = false.obs;
  var chatRoomID = ''.obs;
  var postOfferID = ''.obs;
  var postID = ''.obs;
  var offerID = ''.obs;
  var isExchanged = false.obs;
  var exchangeID = ''.obs;
  var chatRooms = <ChatRoom>[].obs;
  WebSocketChannel? _channel;

  @override
  void onInit() {
    super.onInit();
    ever(tokenController.accessToken, (_) {
      closeWebSocket();
      // เชื่อมต่อใหม่ถ้ามีห้องแชทที่ใช้งานอยู่
      if (chatRoomID.value != '') {
        connectWebSocket(chatRoomID.value);
      }
    });
  }

  var isWebSocketConnected = false.obs;

  /// ฟังก์ชันเชื่อมต่อ WebSocket
  void connectWebSocket(String roomID) async {
    chatRoomID(roomID);
    // fetchMessages(chatRoomID.value);
    if (_channel != null || isWebSocketConnected.value) {
      print("WebSocket is already connected.");
      return;
    }

    final token = tokenController.accessToken.value;
    if (token == null || token.isEmpty) {
      print("No access token available.");
      return;
    }

    final wsUrl = '${dotenv.env['WS_URL']}/$roomID';
    print('---------------------------Print Url-----------------------------');
    print(wsUrl);

    try {
      // ✅ ใช้ WebSocket.connect() พร้อมส่ง Headers
      final socket = await WebSocket.connect(
        wsUrl,
        headers: {
          'Authorization': 'Bearer $token', // ✅ ส่ง Token ใน Header
        },
      );

      _channel = IOWebSocketChannel(socket); // ✅ ใช้ IOWebSocketChannel แทน

      isWebSocketConnected.value = true; // ตั้งค่าสถานะเป็นเชื่อมต่อแล้ว

      _channel!.stream.listen(
        (message) {
          try {
            final jsonData = jsonDecode(message);

            final messageData = jsonDecode(jsonData['message']);

            if (jsonData is Map<String, dynamic>) {
              if (jsonData.containsKey('message')) {
                // กรณีที่ JSON เป็น Message เดี่ยว
                final newMessage = Message(
                  content: messageData['message'],
                  type: messageData['type'], // ตั้งค่า type เป็น default
                  sendAt: DateTime.parse(messageData['timestamp']),
                  username:
                      jsonData['username'], // ตั้งค่า username เป็น default
                );

                // เพิ่มข้อความลงในห้องแชทที่มีอยู่
                if (chatRooms.isNotEmpty) {
                  chatRooms.first.messages.add(newMessage);
                  chatRooms.refresh(); // อัปเดต UI
                } else {
                  chatRooms.add(ChatRoom(
                    date: DateTime.now().toIso8601String(),
                    messages: [newMessage],
                  ));
                }
              } else if (jsonData.containsKey('messages')) {
                // กรณีที่ JSON เป็น ChatRoom ตาม Model
                List<dynamic> rawData = jsonData['messages'];
                List<Message> chatList =
                    rawData.map((item) => Message.fromJson(item)).toList();
                chatRooms.assignAll([
                  ChatRoom(
                    date: jsonData['date'],
                    messages: chatList,
                  )
                ]);
              } else {
                print("Unexpected JSON format: $jsonData");
              }
            }
          } catch (e) {
            print("Failed to parse WebSocket message: $e");
          }
        },
        onError: (error) {
          print("WebSocket Error: $error");
          closeWebSocket();
        },
        onDone: () {
          print("WebSocket Connection Closed");
          closeWebSocket();
        },
      );

      print("Connected to WebSocket: $wsUrl");
    } catch (e) {
      print("Failed to connect WebSocket: $e");
      closeWebSocket();
    }
  }

  /// ฟังก์ชันส่งข้อความผ่าน WebSocket
  Future<bool> sendMessage(String message, String roomID) async {
    if (_channel == null || !isWebSocketConnected.value) {
      print("WebSocket is not connected. Cannot send message.");
      return false;
    }

    final data = jsonEncode({
      "message": message,
      "type": 'text',
      "timestamp": DateTime.now().toIso8601String(),
    });

    _channel!.sink.add(data);

    try {
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading.value = false;
        return false;
      }
      final token = tokenController.accessToken.value;
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '${dotenv.env['API_URL']}/chatrooms/$roomID/messages'), // เปลี่ยน URL ตามจริง
      );
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['message'] = message;

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        // Get.snackbar('สำเร็จ', 'ข้อความถูกส่งไปยังผู้ใช้อีกท่านแล้ว');
        print("Succress to send message.");
        return true;
      } else {
        Get.snackbar(
            'แจ้งเตือน', 'เกิดข้อผิดพลาดในการเก็บข้อมูลของข้อความที่ส่งไป');
        Get.snackbar('แจ้งเตือน', response.body);
        print("Error: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception: $e in ChatController");
      return false;
    }
  }

  /// ฟังก์ชันส่งข้อความผ่าน WebSocket
  Future<bool> sendImage(File imageFile, String roomID) async {
    if (_channel == null || !isWebSocketConnected.value) {
      print("WebSocket ไม่ได้เชื่อมต่อ ไม่สามารถส่งไฟล์ได้");
      return false;
    }

    try {
      if (tokenController.accessToken.value == null) {
        print("ไม่มี access token");
        return false;
      }

      final token = tokenController.accessToken.value;

      // ดึง MIME type ของไฟล์
      String? mimeType = lookupMimeType(imageFile.path);

      // ตรวจสอบว่าไฟล์เป็นประเภทที่รองรับหรือไม่
      const allowedMimeTypes = {
        "image/jpeg": true,
        "image/jpg": true,
        "image/png": true,
        "image/gif": true,
      };

      if (mimeType == null || !allowedMimeTypes.containsKey(mimeType)) {
        print("ประเภทไฟล์ไม่รองรับ: $mimeType");
        Get.snackbar('แจ้งเตือน', 'ประเภทไฟล์ไม่รองรับ');
        return false;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${dotenv.env['API_URL']}/chatrooms/$roomID/messages'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      // เพิ่มไฟล์ภาพ
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType.parse(mimeType),
      ));

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print("อัปโหลดรูปภาพสำเร็จ!");
        final jsonData = jsonDecode(response.body);

        final data = jsonEncode({
          "message": jsonData['data']['content'],
          "type": 'file',
          "timestamp": DateTime.now().toIso8601String(),
        });

        _channel!.sink.add(data);
        return true;
      } else {
        Get.snackbar(
            'แจ้งเตือน', 'เกิดข้อผิดพลาดในการเก็บข้อมูลของรูปที่ส่งไป');
        Get.snackbar('แจ้งเตือน', response.body);
        print("เกิดข้อผิดพลาด: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Exception: $e ใน ChatController");
      return false;
    }
  }

  /// ปิด WebSocket เมื่อไม่ใช้งาน
  void closeChatRoom() {
    chatRooms.clear();
    print('clear message');
  }

  void closeWebSocket() {
    if (_channel == null || !isWebSocketConnected.value) {
      print("WebSocket is already closed.");
      return;
    }

    _channel?.sink.close(ws_status.normalClosure);
    _channel = null;
    isWebSocketConnected.value = false; // อัปเดตสถานะ
  }

  Future<void> fetchMessages(String roomID) async {
    if (tokenController.accessToken.value?.isEmpty ?? true) {
      Get.snackbar('Error', 'No access token found.');
      return;
    }

    isLoading(true);
    try {
      final token = tokenController.accessToken.value!;
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/chatrooms/$roomID'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        try {
          var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
          // final jsonData = jsonDecode(response.body);

          if (jsonData is Map<String, dynamic> &&
              jsonData.containsKey('data')) {
            postOfferID(jsonData['data']['post_offer_id']);
            postID(jsonData['data']['post_id']);
            offerID(jsonData['data']['offer_id']);
            isExchanged(jsonData['data']['is_exchanged']);
            exchangeID(jsonData['data']['exchange_id']);
            print(
                '-------------------------post and offer-------------------------');
            print(postOfferID);
            print(postID);
            print(offerID);
            print(isExchanged.toString());
            print(exchangeID);
            List<dynamic> rawData = jsonData['data']['messages_by_date'];
            List<ChatRoom> chatList =
                rawData.map((item) => ChatRoom.fromJson(item)).toList();
            chatRooms.assignAll(chatList);
          } else {
            Get.snackbar("Error", "Invalid response format");
          }
        } catch (e) {
          print("Error parsing JSON: $e");
        }
      } else {
        Get.snackbar(
            "Error", "Failed to fetch messages (${response.statusCode})");
      }
    } catch (e) {
      Get.snackbar(
          "Error", "An error occurred: ${e.toString()} in ChatController");
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateChatMessageStatus(String roomID) async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value?.isEmpty ?? true) {
        Get.snackbar('Error', 'No access token found.');
        return;
      }
      final token = tokenController.accessToken.value!;
      final response = await http.patch(
        Uri.parse('${dotenv.env['API_URL']}/chatrooms/$roomID/messages/read'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        // final jsonData = jsonDecode(response.body);
        print(jsonData.toString());
        isLoading(false);
        // Get.snackbar("สำเร็จ", "อัพเดทสถานะข้อความล่าสุดภายในห้องแชทแล้ว");
      } else {
        Get.snackbar("แจ้งเตือน",
            "เกิดข้อผิดพลาในการอัพเดทสถานะของห้องแชท (${response.statusCode})");
      }
    } catch (e) {
      Get.snackbar(
          "Error", "An error occurred: ${e.toString()} in ChatController");
    } finally {
      isLoading(false);
    }
  }

  Future<void> leaveChatRoom(String roomID) async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value?.isEmpty ?? true) {
        Get.snackbar('Error', 'No access token found.');
        return;
      }
      final token = tokenController.accessToken.value!;
      final response = await http.patch(
        Uri.parse('${dotenv.env['API_URL']}/chatrooms/$roomID/leave'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        print(jsonData.toString());
        isLoading(false);
        // Get.snackbar("สำเร็จ", "อัพเดทสถานะข้อความล่าสุดภายในห้องแชทแล้ว");
      } else if (response.statusCode == 403) {
        Get.snackbar("แจ้งเตือน", "ไม่สามารถปิดห้องแชทได้ในขณะนี้");
      } else {
        Get.snackbar("แจ้งเตือน",
            "เกิดข้อผิดพลาในปิดห้องแชทนี้ (${response.statusCode})");
      }
    } catch (e) {
      Get.snackbar(
          "Error", "An error occurred: ${e.toString()} in ChatController");
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    closeWebSocket(); // ปิด WebSocket เมื่อ Controller ถูกปิด
    super.onClose();
  }
}
