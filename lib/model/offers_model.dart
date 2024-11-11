class Offers {
  String id;
  String title;
  String description;
  String subCollectionName;
  String coverImage;

  Offers({
    required this.id,
    required this.title,
    required this.description,
    required this.subCollectionName,
    required this.coverImage,
  });

  // ฟังก์ชันแปลง JSON เป็น Model
  factory Offers.fromJson(Map<String, dynamic> json) {
    return Offers(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      subCollectionName: json['sub_collection_name'],
      coverImage: json['cover_image'],
    );
  }

  // ฟังก์ชันแปลง Model เป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'sub_collection_name': subCollectionName,
      'cover_image': coverImage,
    };
  }
}
