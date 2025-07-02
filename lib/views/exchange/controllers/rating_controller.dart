import 'package:get/get.dart';

class RatingController extends GetxController {
  var selectedRating = 0.obs;

  void setRating(int rating) {
    selectedRating.value = rating;
  }
}
