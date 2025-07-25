import 'dart:io';

class Post {
  String title;
  String description;
  String flaw;
  String desiredItem;
  String subCollectionId;
  int subDistrictId;
  // String? brand;
  // String? mainCategory;
  // String? subCategory;
  List<File> mediaFiles;

  Post({
    required this.title,
    required this.description,
    required this.flaw,
    required this.desiredItem,
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
      'desired_item': desiredItem,
      'sub_collection_id': subCollectionId,
      'sub_district_id': subDistrictId,
      // 'brand': brand,
      // 'main_category': mainCategory,
      // 'sub_category': subCategory,
    };
  }
}
