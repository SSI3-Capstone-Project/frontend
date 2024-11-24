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

  // จำเป็นต้องตั้ง accessToken ที่ได้รับจากการ login หรืออื่นๆ
  String? accessToken;

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    accessToken = tokenController.accessToken.value;
    fetchProvince();
  }

  void fetchProvince() async {
    isLoading(true);
    if (accessToken == null) {
      Get.snackbar('Error', 'No access token found.');
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/provinces'),
        headers: {
          'Authorization': 'Bearer $accessToken', // แนบ Bearer Token
        },
      );
      if (response.statusCode == 200) {
        var data = jsonDecode(utf8.decode(response.bodyBytes));
        provinces.value = List<Province>.from(
          data['data'].map((item) => Province.fromJson(item)),
        );
      } else {
        Get.snackbar('Error', 'Failed to fetch provinces');
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }
}
