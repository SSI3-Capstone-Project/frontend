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

  // จำเป็นต้องตั้ง accessToken ที่ได้รับจากการ login หรืออื่นๆ
  String? accessToken;

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    accessToken = tokenController.accessToken.value;
    fetchBrands();
  }

  void fetchBrands() async {
    await tokenController.loadTokens();
    isLoading(true);
    if (accessToken == null) {
      Get.snackbar('Error', 'No access token found.');
      return;
    }
    try {
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
      } else {
        Get.snackbar('Error', 'Failed to fetch brands');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }
}
