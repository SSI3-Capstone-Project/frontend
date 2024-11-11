import 'package:get/get.dart';

class BrandControllerTwo extends GetxController {
  // เก็บสถานะแบรนด์ในรูปแบบ Map
  var selectedBrands = <String, bool>{
    "Nike": false,
    "Adidas": false,
    "Puma": false,
    "Under Armour": false,
    "New Balance": false,
  }.obs;

  get brands => null;

  get selectedCollection => null;

  // ฟังก์ชันสำหรับอัปเดตการเลือกแบรนด์
  void toggleBrandSelection(String brand, bool isSelected) {
    selectedBrands[brand] = isSelected;
  }

  void selectBrand(selectedBrand) {}

  void selectCollection(selectedCollection) {}
}
