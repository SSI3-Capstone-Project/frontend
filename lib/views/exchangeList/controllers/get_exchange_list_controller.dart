import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'package:mbea_ssi3_front/views/exchangeList/models/get_exchange_list_model.dart';

class ExchangeListController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var exchangeList = <ExchangeListModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExchangeList();
  }

  Future<void> fetchExchangeList({String status = "", String? username}) async {
    try {
      isLoading(true);
      if (tokenController.accessToken.value == null) {
        return;
      }

      final token = tokenController.accessToken.value;
      String url = '${dotenv.env['API_URL']}/exchanges';

      // เก็บ query parameters ใน list แล้วค่อยเอาไปรวม
      List<String> queryParams = [];

      if (status.isNotEmpty) {
        queryParams.add('status=$status');
      }
      if (username != null && username.isNotEmpty) {
        queryParams.add('username=$username');
      }

      if (queryParams.isNotEmpty) {
        url += '?${queryParams.join('&')}';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        var jsonData = jsonDecode(utf8.decode(response.bodyBytes));
        var exchangeListData = jsonData['data'];
        if (exchangeListData != null &&
            exchangeListData is List &&
            exchangeListData.isNotEmpty) {
          exchangeList.value = exchangeListData
              .map((item) => ExchangeListModel.fromJson(item))
              .toList();
        } else {
          exchangeList.clear();
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load exchange list',
          backgroundColor: Colors.grey.shade200,
        );
      }
    } finally {
      isLoading(false);
    }
  }
}
