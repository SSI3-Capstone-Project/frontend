import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'dart:convert';

import 'package:mbea_ssi3_front/model/province_model.dart';

class ProvinceController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var provinces = <Province>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    fetchProvince();
  }

  void fetchProvince() async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading(false);
        return;
      }
      final token = tokenController.accessToken.value;
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/provinces'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
        },
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        provinces.value = List<Province>.from(
          data['data'].map((item) => Province.fromJson(item)),
        );
        isLoading(false);
      } else {
        Get.snackbar(
          'แจ้งเตือน',
          'เกิดปัญหาในการดึงข้อมูลสถานที่',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading(false);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()} in ProvinceController',
        backgroundColor: Colors.grey.shade200,
      );
      isLoading(false);
    } finally {
      isLoading(false);
    }
  }
}
