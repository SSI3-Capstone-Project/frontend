import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'package:mbea_ssi3_front/views/exchange/models/exchange_model.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

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
        Get.snackbar('แจ้งเตือน', 'คุณได้อัพเดทสถานะการแลกเปลี่ยนนี้แล้ว');
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

  Future<bool> sendUserReview(String exchangeID, int rating, String? comment,
      List<Map<String, dynamic>> mediaList) async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        isLoading(false);
        return false;
      }
      final token = tokenController.accessToken.value;

      var uri =
          Uri.parse('${dotenv.env['API_URL']}/exchanges/$exchangeID/reviews');

      var request = http.MultipartRequest("POST", uri)
        ..headers["Authorization"] = "Bearer $token"
        ..fields["rating"] = rating.toString()
        ..fields["comment"] = comment ?? "";

      // เพิ่มไฟล์ทั้งหมดใน request จาก mediaList
      for (var media in mediaList) {
        if (media["file"] is File) {
          File file = media["file"];

          // ตรวจสอบ MIME Type ตามไฟล์จริง
          String? mimeType =
              lookupMimeType(file.path) ?? "application/octet-stream";
          String fileExtension = path.extension(file.path).toLowerCase();

          // ตรวจสอบชนิดของไฟล์
          if (fileExtension == ".mp4") {
            mimeType = "video/mp4";
          } else if (fileExtension == ".png") {
            mimeType = "image/png";
          } else if (fileExtension == ".jpg" || fileExtension == ".jpeg") {
            mimeType = "image/jpeg";
          } else if (fileExtension == ".gif") {
            mimeType = "image/gif";
          }

          String fieldName = "files"; // ใช้ชื่อ key เป็น "files" ตามที่ต้องการ
          request.files.add(await http.MultipartFile.fromPath(
              fieldName, file.path,
              contentType: MediaType.parse(mimeType)));
        }
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        print(jsonData);
        Get.snackbar('สำเร็จ', 'คุณส่งรีวิวผู้ใช้งานท่านนี้สำเร็จแล้ว');
        isLoading(false);
        return true;
      } else if (response.statusCode == 403) {
        print(jsonData);
        Get.snackbar('แจ้งเตือน',
            'คุณสามารถส่งรีวิวได้หลังจากการแลกเปลี่ยนเสร็จสิ้นแล้วเท่านั้น');
        isLoading(false);
        return false;
      } else if (response.statusCode == 409) {
        print(jsonData);
        Get.snackbar('แจ้งเตือน', 'คุณได้รีวิวผู้ใช้งานท่านนี้เรียบร้อยแล้ว');
        isLoading(false);
        return false;
      } else {
        print(jsonData);
        Get.snackbar('แจ้งเตือน', 'เกิดปัญหาระหว่างการส่งรีวิวผู้ใช้งาน');
        isLoading(false);
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
      isLoading(false);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
