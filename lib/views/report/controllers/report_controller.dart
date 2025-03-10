import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';

enum ReportType {
  inappropriateBehavior,
  scam,
  productMismatch,
  damagedProduct,
  others,
}

extension ReportTypeExtension on ReportType {
  String get value {
    switch (this) {
      case ReportType.inappropriateBehavior:
        return "inappropriate_behavior";
      case ReportType.scam:
        return "scam";
      case ReportType.productMismatch:
        return "product_mismatch";
      case ReportType.damagedProduct:
        return "damaged_product";
      case ReportType.others:
        return "others";
    }
  }

  String get displayName {
    switch (this) {
      case ReportType.inappropriateBehavior:
        return "พฤติกรรมไม่เหมาะสม";
      case ReportType.scam:
        return "หลอกลวง";
      case ReportType.productMismatch:
        return "สินค้าไม่ตรงกัน";
      case ReportType.damagedProduct:
        return "สินค้าเสียหาย";
      case ReportType.others:
        return "อื่นๆ";
    }
  }
}

class ReportController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var isLoading = false.obs;

  Future<bool> createExchangeReport(
      String exchangeId, ReportType reportType, String reason) async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        Get.snackbar('Error', 'No access token found.');
        isLoading(false);
        return false;
      }
      final token = tokenController.accessToken.value;

      final body = jsonEncode({
        "report_type": reportType.value,
        "reason": reason,
      });

      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/exchanges/$exchangeId/reports'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print(jsonData);
        Get.snackbar('สำเร็จ', 'การสร้างรายงานสำเร็จ');
        return true;
      } else {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print(jsonData);
        Get.snackbar('แจ้งเตือน', 'เกิดปัญหาระหว่างการส่งรายงาน');
        return false;
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
      return false;
    } finally {
      isLoading(false);
    }
  }
}
