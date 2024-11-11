import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:mbea_ssi3_front/model/brand_model.dart';

class BrandController extends GetxController {
  var brands = <Brand>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBrands();
  }

  void fetchBrands() async {
    isLoading(true);
    try {
      final response =
          await http.get(Uri.parse('${dotenv.env['API_URL']}/brands'));
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
