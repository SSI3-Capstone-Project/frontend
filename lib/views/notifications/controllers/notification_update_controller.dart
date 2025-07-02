import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/notifications/controllers/notification_list_get_controller.dart';

import '../models/notification_list_get_model.dart' as custom;

class NotificationUpdateController extends GetxController {
  final tokenController = Get.find<TokenController>();
  final NotificationController notificationController =
      Get.put(NotificationController());
  var notifications = <custom.Notification>[].obs;
  var isLoading = false.obs;
  var currentTabIndex = 0.obs;

  Future<void> markNotificationAsRead(
      String notificationId, String type) async {
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
        // Update the notification in the list
        int index = notificationController.notifications
            .indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notificationController.notifications[index].isRead = true;
          notificationController.notifications.refresh(); // Refresh the UI

          // Fetch notifications based on current tab
          if (currentTabIndex.value == 0) {
            // If we're on "All" tab, fetch all notifications
            notificationController.fetchNotifications();
          } else {
            // Otherwise fetch by type
            notificationController.setNotificationType(type);
          }
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to mark notification as read',
          backgroundColor: Colors.grey.shade200,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred',
        backgroundColor: Colors.grey.shade200,
      );
    }
  }
}
