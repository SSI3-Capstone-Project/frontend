import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'dart:convert';

import 'package:mbea_ssi3_front/model/brand_model.dart';

class BrandController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var brands = <Brand>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    fetchBrands();
  }

  void fetchBrands() async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading(false);
        return;
      }
      final token = tokenController.accessToken.value;
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/brands'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
        },
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        brands.value = List<Brand>.from(
          data['data'].map((item) => Brand.fromJson(item)),
        );
        isLoading(false);
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch brands',
          backgroundColor: Colors.grey.shade200,
        );
        isLoading(false);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()} in BrandController',
        backgroundColor: Colors.grey.shade200,
      );
      isLoading(false);
    } finally {
      isLoading(false);
    }
  }
}
