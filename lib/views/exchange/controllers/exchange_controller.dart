import 'dart:io';
import 'package:flutter/material.dart';
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
        Get.snackbar(
          'แจ้งเตือน',
          'ไม่สามารถดึงรายละเอียดการแลกเปลี่ยนได้',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()} in ExchangeController',
        backgroundColor: Colors.grey.shade200,
      );
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
        Get.snackbar(
          'สำเร็จ',
          'อัพเดทสถานะการแลกเปลี่ยนสำเร็จ',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading(false);
        return true;
      } else if (response.statusCode == 409) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print(jsonData);
        Get.snackbar(
          'แจ้งเตือน',
          'คุณได้อัพเดทสถานะการแลกเปลี่ยนนี้แล้ว',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading(false);
        return false;
      } else if (response.statusCode == 403) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print(jsonData);
        Get.snackbar(
          'แจ้งเตือน',
          'คุณจะสามารถยกเลิกได้เมื่อผ่านไปหนึงชั่วโมงหลังเวลานัด',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading(false);
        return false;
      } else {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print(jsonData);
        Get.snackbar(
          'แจ้งเตือน',
          'เกิดปัญหาระหว่างการอัพเดทสถานะการแลกเปลี่ยน',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading(false);
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()} in ExchangeController',
        backgroundColor: Colors.grey.shade200,
      );
      isLoading(false);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createExchangeCharge(String exchangeID, String cardID) async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        isLoading(false);
        return false;
      }

      final token = tokenController.accessToken.value;

      final body = jsonEncode({"card_id": cardID});

      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/exchanges/$exchangeID/charges'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: body,
      );
      var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print(jsonData);
        Get.snackbar(
          'สำเร็จ',
          'สร้างรายการชำระเงินเรียบร้อยแล้ว',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading.value = false;
        return true;
      } else if (response.statusCode == 400) {
        print(jsonData);
        Get.snackbar(
          'แจ้งเตือน',
          'ไม่มีการแนบเลขการ์ดสำหรับชำระเงิน หรือ รูปแบบไม่ถูกต้อง',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading.value = false;
        return false;
      } else if (response.statusCode == 404) {
        print(jsonData);
        Get.snackbar(
          'แจ้งเตือน',
          'ไม่พบรายการชำระเงินนี้',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading.value = false;
        return false;
      } else {
        print(jsonData);
        Get.snackbar(
          'แจ้งเตือน',
          'เกิดปัญหาในการสร้างรายการชำระเงินนี้',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      print(e);
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()} in ExchangeController',
        backgroundColor: Colors.grey.shade200,
      );
      return false;
    } finally {
      isLoading(false);
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
        Get.snackbar(
          'สำเร็จ',
          'คุณส่งรีวิวผู้ใช้งานท่านนี้สำเร็จแล้ว',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading(false);
        return true;
      } else if (response.statusCode == 400) {
        var errorMessages = (jsonData['errors'] as List).map((e) {
          switch (e['field']) {
            case 'files':
              return 'กรุณาแนบรูปภาพหรือวีดีโออย่างน้องหนึ่งไฟล์';
            case 'Rating':
              return 'กรุณากดให้คะแนนการแลกเปลี่ยนครั้งนี้';
            default:
              return '${e['field']}: ${e['error']}';
          }
        }).join(', ');

        Get.snackbar(
          'แจ้งเตือน',
          errorMessages,
          backgroundColor: Colors.grey.shade200,
        );
        print(errorMessages); // Debug log
        isLoading.value = false;
        return false;
      } else if (response.statusCode == 403) {
        print(jsonData);
        Get.snackbar(
          'แจ้งเตือน',
          'คุณสามารถส่งรีวิวได้หลังจากการแลกเปลี่ยนเสร็จสิ้นแล้วเท่านั้น',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading(false);
        return false;
      } else if (response.statusCode == 404) {
        print(jsonData);
        Get.snackbar(
          'แจ้งเตือน',
          'ไม่พบรายการแลกเปลี่ยนนี้ในระบบ',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading.value = false;
        return false;
      } else if (response.statusCode == 409) {
        print(jsonData);
        Get.snackbar(
          'แจ้งเตือน',
          'คุณได้รีวิวผู้ใช้งานท่านนี้เรียบร้อยแล้ว',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading(false);
        return false;
      } else {
        print(jsonData);
        Get.snackbar(
          'แจ้งเตือน',
          'เกิดปัญหาระหว่างการส่งรีวิวผู้ใช้งาน',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading(false);
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        backgroundColor: Colors.grey.shade200,
      );
      isLoading(false);
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
