import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'dart:convert';

import 'package:mbea_ssi3_front/views/exchange/models/exchange_model.dart';

class ExchangeController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var exchange = Rxn<ExchangeModel>();
  var isLoading = false.obs;

  Future<bool> fetchExchangeDetails(String exchangeId) async {
    try {
      exchange.value = null;
      isLoading.value = true;
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading(false);
        return false;
      }
      final token = tokenController.accessToken.value;
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/exchanges/$exchangeId'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        exchange.value = ExchangeModel.fromJson(jsonData['data']);
        isLoading.value = false;
        return true;
      } else {
        exchange.value = null;
        Get.snackbar('แจ้งเตือน', 'ไม่สามารถดึงรายละเอียดการแลกเปลี่ยนได้');
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      Get.snackbar(
          'Error', 'An error occurred: ${e.toString()} in ExchangeController');
      isLoading.value = false;
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateExchangeStatus(String exchangeID, String status) async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading(false);
        return false;
      }
      final token = tokenController.accessToken.value;

      final body = jsonEncode({"status": status});

      final response = await http.patch(
        Uri.parse('${dotenv.env['API_URL']}/exchanges/$exchangeID'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: body,
      );
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print(jsonData);
        Get.snackbar('สำเร็จ', 'อัพเดทสถานะการแลกเปลี่ยนสำเร็จ');
        isLoading(false);
        return true;
      } else if (response.statusCode == 409) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print(jsonData);
        Get.snackbar('แจ้งเตือน', 'คุณได้เช็คอินสถานที่เรียบร้อยแล้ว');
        isLoading(false);
        return false;
      } else if (response.statusCode == 403) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print(jsonData);
        Get.snackbar('แจ้งเตือน',
            'คุณจะสามารถยกเลิกได้เมื่อผ่านไปหนึงชั่วโมงหลังเวลานัด');
        isLoading(false);
        return false;
      } else {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print(jsonData);
        Get.snackbar(
            'แจ้งเตือน', 'เกิดปัญหาระหว่างการอัพเดทสถานะการแลกเปลี่ยน');
        isLoading(false);
        return false;
      }
    } catch (e) {
      Get.snackbar(
          'Error', 'An error occurred: ${e.toString()} in ExchangeController');
      isLoading(false);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
