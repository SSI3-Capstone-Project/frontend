import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/views/home/models/product_model.dart';

class ProductController extends GetxController {
  var productList = <Product>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      isLoading(true);
      final response = await http.get(
        Uri.parse('https://671e5d3c1dfc4299198215f1.mockapi.io/products'),
      );
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(response.body) as List;
        productList.value =
            jsonData.map((item) => Product.fromJson(item)).toList();
      } else {
        Get.snackbar('Error', 'Failed to load products');
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> updateProduct(
      String id, String title, String description) async {
    try {
      isLoading(true);
      final response = await http.put(
        Uri.parse('https://671e5d3c1dfc4299198215f1.mockapi.io/products/$id'),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'title': title,
          'description': description,
        }),
      );

      if (response.statusCode == 200) {
        int index = productList.indexWhere((product) => product.id == id);
        if (index != -1) {
          productList[index].title = title;
          productList[index].description = description;
          productList.refresh();
        }
        Get.snackbar('Success', 'Product updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to update product');
      }
    } finally {
      isLoading(false);
    }
  }
}
