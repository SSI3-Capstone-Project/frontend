import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import '../models/card_details_get_model.dart';

class GetOmiseCustomerCardDetailController extends GetxController {
  final tokenController = Get.find<TokenController>();

  var cardDetail = Rxn<GetOmiseCustomerCardDetail>();
  var isLoading = false.obs;

  Future<void> getOmiseCustomerCardDetail(String cardId) async {
    isLoading.value = true;

    try {
      if (tokenController.accessToken.value == null) {
        isLoading.value = false;
        return;
      }
      final token = tokenController.accessToken.value;
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/user/credit-cards/$cardId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final utf8Data = utf8.decode(response.bodyBytes);
        final data = json.decode(utf8Data)['data'];
        cardDetail.value = GetOmiseCustomerCardDetail.fromJson(data);
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch card details',
          backgroundColor: Colors.grey.shade200,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e in GetOmiseCustomerCardDetailController',
        backgroundColor: Colors.grey.shade200,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
