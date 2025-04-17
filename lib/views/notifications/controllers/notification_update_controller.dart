import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';

import '../models/notification_list_get_model.dart';

class NotificationUpdateController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var notifications = <Notification>[].obs;
  var isLoading = false.obs;

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      if (tokenController.accessToken.value == null) {
        return;
      }

      final token = tokenController.accessToken.value;
      final url = '${dotenv.env['API_URL']}/notifications/$notificationId/read';

      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // สมมติว่าใน model มี isRead หรือ is_read
        int index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index].isRead = true; // หรือ is_read = true ถ้าใช้ snake_case
          notifications.refresh(); // รีเฟรช UI
        }
      } else {
        Get.snackbar('Error', 'Failed to mark notification as read');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred');
    }
  }
}