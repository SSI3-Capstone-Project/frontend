class PostOffers {
  String id;
  String title;
  String description;
  String subCollectionName;
  String coverImage;
  String userName;
  String imageURL;
  String location;

  PostOffers({
    required this.id,
    required this.title,
    required this.description,
    required this.subCollectionName,
    required this.coverImage,
    required this.userName,
    required this.imageURL,
    required this.location,
  });

  // ฟังก์ชันแปลง JSON เป็น Model
  factory PostOffers.fromJson(Map<String, dynamic> json) {
    return PostOffers(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      subCollectionName: json['sub_collection_name'],
      coverImage: json['cover_image'],
      userName: json['username'],
      imageURL: json['image_url'],
      location: json['location'],
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
      'username': userName,
      'image_url': imageURL,
      'location': location,
    };
  }
}
