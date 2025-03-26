import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../controller/token_controller.dart';
import '../models/notification_list_get_model.dart';

class NotificationController extends GetxController {
  final tokenController = Get.find<TokenController>();

  var notifications = RxList<Notification>();
  var isLoading = false.obs;

  // เพิ่มตัวแปรสำหรับเก็บประเภทการแจ้งเตือน
  var notificationType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();  // เรียกข้อมูลเริ่มต้นเมื่อเริ่มใช้งาน
  }

  // แก้ไขฟังก์ชัน fetchNotifications ให้รองรับ notification_type
  Future<void> fetchNotifications({String type = ''}) async {
    isLoading.value = true;

    try {
      // ถ้าไม่มี access token ให้หยุด
      if (tokenController.accessToken.value == null) {
        isLoading.value = false;
        return;
      }

      final token = tokenController.accessToken.value;

      // กำหนด URL ที่จะใช้ในการเรียก API
      final url = type.isEmpty
          ? '${dotenv.env['API_URL']}/notifications'
          : '${dotenv.env['API_URL']}/notifications?notification_type=$type';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final utf8Data = utf8.decode(response.bodyBytes);
        final decodedJson = json.decode(utf8Data);
        final notificationResponse = NotificationResponse.fromJson(decodedJson);

        notifications.value = notificationResponse.data;
      } else {
        Get.snackbar('Error', 'Failed to fetch notifications');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e in NotificationController');
    } finally {
      isLoading.value = false;
    }
  }

  // ฟังก์ชันใหม่ที่สามารถอัพเดตประเภทการแจ้งเตือน
  void setNotificationType(String type) {
    notificationType.value = type;
    fetchNotifications(type: type);  // เรียก API พร้อมกับประเภทที่เลือก
  }
}
