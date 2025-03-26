import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import '../models/card_list_get_model.dart';

class CardListController extends GetxController {
  final tokenController = Get.find<TokenController>();

  var cards = <GetOmiseCustomerCard>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCustomerCards();
  }

  Future<void> fetchCustomerCards() async {
    isLoading.value = true;

    try {
      if (tokenController.accessToken.value == null) {
        isLoading.value = false;
        return;
      }
      final token = tokenController.accessToken.value;
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/user/credit-cards'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final utf8Data = utf8.decode(response.bodyBytes);
        final decodedJson = json.decode(utf8Data);

        // ตรวจสอบว่ามีข้อมูลและเป็น List หรือไม่
        if (decodedJson['data'] is List) {
          final List<dynamic> data = decodedJson['data'];
          cards.value =
              data.map((card) => GetOmiseCustomerCard.fromJson(card)).toList();
        } else {
          cards.value = []; // ตั้งค่าให้เป็น array ว่างหากไม่มีข้อมูล
        }
      } else {
        Get.snackbar('Error', 'Failed to fetch customer cards');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e in OmiseCardController');
    } finally {
      isLoading.value = false;
    }
  }
}