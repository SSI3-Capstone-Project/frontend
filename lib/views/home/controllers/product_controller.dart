import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/home/models/product_model.dart';

class ProductController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var productList = <Product>[].obs;
  var isLoading = false.obs;

  // จำเป็นต้องตั้ง accessToken ที่ได้รับจากการ login หรืออื่นๆ
  String? accessToken;

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    accessToken = tokenController.accessToken.value;
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      await tokenController.loadTokens();
      final token = tokenController.accessToken.value;
      isLoading(true);
      if (accessToken == null) {
        Get.snackbar('Error', 'No access token found.');
        return;
      }
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/posts'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
        },
      );
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        var postData = jsonData['data'];
        if (postData != null && postData is List && postData.isNotEmpty) {
          productList.value =
              postData.map((item) => Product.fromJson(item)).toList();
        } else {
          productList.clear(); // Clear the list if no data is present
          // Get.snackbar('แจ้งเตือน', 'ไม่พบโพสต์ในระบบ');
        }
        // productList.value =
        //     jsonData.map((item) => Product.fromJson(item)).toList();
      } else {
        Get.snackbar('Error', 'Failed to load products');
      }
    } finally {
      isLoading(false);
    }
  }

  // Future<void> updateProduct(
  //     String id, String title, String description) async {
  //   try {
  //     isLoading(true);
  //     final response = await http.put(
  //       Uri.parse('https://671e5d3c1dfc4299198215f1.mockapi.io/products/$id'),
  //       headers: {'Content-Type': 'application/json; charset=UTF-8'},
  //       body: jsonEncode({
  //         'title': title,
  //         'description': description,
  //       }),
  //     );

  //     if (response.statusCode == 200) {
  //       int index = productList.indexWhere((product) => product.id == id);
  //       if (index != -1) {
  //         productList[index].title = title;
  //         productList[index].description = description;
  //         productList.refresh();
  //       }
  //       Get.snackbar('Success', 'Product updated successfully');
  //     } else {
  //       Get.snackbar('Error', 'Failed to update product');
  //     }
  //   } finally {
  //     isLoading(false);
  //   }
  // }
}
