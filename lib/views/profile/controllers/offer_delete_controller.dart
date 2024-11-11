import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class OfferDeleteController extends GetxController {
  var isLoading = false.obs;

  Future<void> deleteOffer(String offerId) async {
    isLoading.value = true;
    try {
      final response = await http.delete(
        Uri.parse('${dotenv.env['API_URL']}/offer/$offerId'),
      );

      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Offer deleted successfully');
      } else {
        Get.snackbar('Error', 'Failed to delete offer');
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
