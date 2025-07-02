import 'dart:io';

class Offer {
  String title;
  String description;
  String flaw;
  String subCollectionId;
  int subDistrictId;
  // String? brand;
  // String? mainCategory;
  // String? subCategory;
  List<File> mediaFiles;

  Offer({
    required this.title,
    required this.description,
    required this.flaw,
    required this.subCollectionId,
    required this.subDistrictId,
    // this.brand,
    // this.mainCategory,
    // this.subCategory,
    required this.mediaFiles,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'flaw': flaw,
      'sub_collection_id': subCollectionId,
      'sub_district_id': subDistrictId,
      // 'brand': brand,
      // 'main_category': mainCategory,
      // 'sub_category': subCategory,
    };
  }
}
