import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mbea_ssi3_front/controller/token_controller.dart';
import 'dart:convert';

import 'package:mbea_ssi3_front/views/address/models/address_model.dart';

class AddressController extends GetxController {
  final tokenController = Get.find<TokenController>();
  var addressList = <Address>[].obs; // Observable list of addresses
  var isLoading = false.obs; // Observable for loading state
  var message = ''.obs; // Observable for API message

  @override
  void onInit() {
    super.onInit();
    // กำหนดค่า accessToken ใน onInit แทนการกำหนดในตัวแปรโดยตรง
    fetchAddresses();
  }

  // @override
  // void onReady() {
  //   super.onReady();
  //   fetchAddresses(); // เรียก API หลังจาก Widget พร้อมแล้ว
  // }

  // Fetch addresses from the API
  // Fetch addresses from the API
  Future<void> fetchAddresses() async {
    try {
      isLoading.value = true;
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading.value = false;
        return;
      }
      final token = tokenController.accessToken.value;
      final response = await http.get(
        Uri.parse('${dotenv.env['API_URL']}/addresses'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(utf8.decode(response.bodyBytes));
        message.value = responseData['message'];

        // ตรวจสอบว่า data เป็น null หรือไม่
        if (responseData['data'] == null) {
          addressList.value = []; // กำหนดค่าให้ addressList เป็นลิสต์ว่าง
        } else {
          var addresses = responseData['data'] as List;
          addressList.value =
              addresses.map((e) => Address.fromJson(e)).toList(); // Parse data
        }
        isLoading.value = false;
      } else {
        message.value = 'Failed to fetch addresses';
        Get.snackbar('Error', 'Failed to fetch addresses');
        isLoading.value = false;
      }
    } catch (e) {
      message.value = 'Error occurred: $e';
      isLoading.value = false;
    }
  }

  Future<bool> addAddress({
    required int subDistrictId,
    required String address,
    required bool isDefault,
  }) async {
    try {
      isLoading.value = true;

      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading.value = false;
        return false;
      }
      final token = tokenController.accessToken.value;

      final response = await http.post(
        Uri.parse('${dotenv.env['API_URL']}/addresses'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
          'Content-Type': 'application/json', // ระบุ Content-Type เป็น JSON
        },
        body: json.encode({
          'sub_district_id': subDistrictId,
          'address': address,
          'is_default': isDefault,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(utf8.decode(response.bodyBytes));
        message.value = responseData['message'] ?? 'Address added successfully';

        // ดึงรายการที่อยู่ใหม่หลังจากเพิ่มสำเร็จ
        fetchAddresses();

        // Get.snackbar('Success', message.value);
        isLoading.value = false;
        return true;
      } else {
        final Map<String, dynamic> responseData =
            json.decode(utf8.decode(response.bodyBytes));
        message.value = responseData['message'] ?? 'Failed to add address';
        print(responseData);
        Get.snackbar('Error', message.value);
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      message.value = 'Error occurred: $e';
      Get.snackbar('Error', message.value);
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> editAddress({
    required String id,
    required int subDistrictId,
    required String address,
    required bool isDefault,
  }) async {
    try {
      print('----------------------------------------------------------------');
      print(subDistrictId);
      print(address);
      print(isDefault);
      print('----------------------------------------------------------------');
      isLoading.value = true;

      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading.value = false;
        return false;
      }
      final token = tokenController.accessToken.value;
      final response = await http.put(
        Uri.parse('${dotenv.env['API_URL']}/addresses/${id}'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
          'Content-Type': 'application/json', // ระบุ Content-Type เป็น JSON
        },
        body: json.encode({
          'sub_district_id': subDistrictId,
          'address': address,
          'is_default': isDefault,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(utf8.decode(response.bodyBytes));
        message.value =
            responseData['message'] ?? 'Address edited successfully';

        // ดึงรายการที่อยู่ใหม่หลังจากเพิ่มสำเร็จ
        fetchAddresses();

        // Get.snackbar('Success', message.value);
        isLoading.value = false;
        return true;
      } else {
        final Map<String, dynamic> responseData =
            json.decode(utf8.decode(response.bodyBytes));
        message.value = responseData['message'] ?? 'Failed to edit address';
        print(responseData);
        Get.snackbar('Error', message.value);
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      message.value = 'Error occurred: $e';
      Get.snackbar('Error', message.value);
      isLoading.value = false;
      return false;
    }
  }

  Future<bool> deleteAddress({
    required String id,
  }) async {
    try {
      isLoading.value = true;
      if (tokenController.accessToken.value == null) {
        // Get.snackbar('Error', 'No access token found.');
        isLoading.value = false;
        return false;
      }
      final token = tokenController.accessToken.value;
      final response = await http.patch(
        Uri.parse('${dotenv.env['API_URL']}/addresses/${id}'),
        headers: {
          'Authorization': 'Bearer $token', // แนบ Bearer Token
          'Content-Type': 'application/json', // ระบุ Content-Type เป็น JSON
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            json.decode(utf8.decode(response.bodyBytes));
        message.value =
            responseData['message'] ?? 'Address deleted successfully';

        // ดึงรายการที่อยู่ใหม่หลังจากเพิ่มสำเร็จ
        fetchAddresses();

        // Get.snackbar('Success', message.value);
        isLoading.value = false;
        return true;
      } else {
        final Map<String, dynamic> responseData =
            json.decode(utf8.decode(response.bodyBytes));
        message.value = responseData['message'] ?? 'Failed to delete address';
        print(responseData);
        Get.snackbar('Error', message.value);
        isLoading.value = false;
        return false;
      }
    } catch (e) {
      message.value = 'Error occurred: $e';
      Get.snackbar('Error', message.value);
      isLoading.value = false;
      return false;
    }
  }
}
