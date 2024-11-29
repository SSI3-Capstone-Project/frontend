import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/home/models/product_detail_model.dart';

class ProductDetailController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var productDetail = Rxn<ProductDetail>();
  var isLoading = false.obs;

  // Access token received from login or other authentication processes
  String? accessToken;

  @override
  void onInit() {
    super.onInit();
    // Initialize accessToken in onInit
    accessToken = tokenController.accessToken.value;
  }

  Future<void> fetchProductDetail(String productId) async {
    try {
      await tokenController.loadTokens();
      final token = tokenController.accessToken.value;
      isLoading(true);
      if (accessToken == null) {
        Get.snackbar('Error', 'No access token found.');
        return;
      }
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/posts/$productId'),
        headers: {
          'Authorization': 'Bearer $token', // Attach Bearer Token
        },
      );
      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        print('Fetched JSON data: $jsonData');
        var productData = jsonData['data'];
        productDetail.value = ProductDetail.fromJson(productData);
      } else {
        Get.snackbar(
            'Error', 'Failed to load product detail: ${response.reasonPhrase}');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }
}
