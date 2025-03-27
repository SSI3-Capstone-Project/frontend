import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';

import '../models/notification_list_get_model.dart';

class NotificationController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var notifications = <Notification>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications({String type = ""}) async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        return;
      }

      final token = tokenController.accessToken.value;
      String url = '${dotenv.env['API_URL']}/notifications';
      if (type.isNotEmpty) {
        url += '?notification_type=$type';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        var notificationsData = jsonData['data'];
        if (notificationsData != null && notificationsData is List && notificationsData.isNotEmpty) {
          notifications.value =
              notificationsData.map((item) => Notification.fromJson(item)).toList();
        } else {
          notifications.clear();
        }
      } else {
        Get.snackbar('Error', 'Failed to load notifications');
      }
    } finally {
      isLoading(false);
    }
  }

  void setNotificationType(String type) {
    fetchNotifications(type: type);
  }
}
