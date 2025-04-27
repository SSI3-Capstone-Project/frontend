import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/home/models/product_model.dart';

class ProductController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var productList = <Product>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    fetchProducts();
  }

  Future<void> fetchProducts({
    String? brandName,
    String? collectionName,
    String? subCollectionName,
    String? title, // ✅ เพิ่ม parameter title
  }) async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        return;
      }
      final token = tokenController.accessToken.value;

      final queryParams = <String, String>{};

      if (brandName != null && brandName.isNotEmpty) {
        queryParams['brand_name'] = brandName;

        if (collectionName != null && collectionName.isNotEmpty) {
          queryParams['collection_name'] = collectionName;

          if (subCollectionName != null && subCollectionName.isNotEmpty) {
            queryParams['sub_collection_name'] = subCollectionName;
          }
        }
      }

      // ✅ เพิ่มการตรวจสอบ title และใส่ลงใน queryParams ถ้ามี
      if (title != null && title.isNotEmpty) {
        queryParams['title'] = title;
      }

      final uri = Uri.parse('${dotenv.env['API_URL']}/posts')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        var postData = jsonData['data'];
        if (postData != null && postData is List && postData.isNotEmpty) {
          productList.value =
              postData.map((item) => Product.fromJson(item)).toList();
        } else {
          productList.clear();
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load products',
          backgroundColor: Colors.grey.shade200,
        );
      }
    } finally {
      isLoading(false);
    }
  }
}
