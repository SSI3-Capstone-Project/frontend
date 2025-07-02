class Brand {
  final String name;
  final List<Collection>? collections;

  Brand({required this.name, this.collections});

  factory Brand.fromJson(Map<String, dynamic> json) {
    return Brand(
      name: json['name'],
      collections: json['collections'] != null
          ? List<Collection>.from(
              json['collections'].map((x) => Collection.fromJson(x)))
          : null,
    );
  }
}

class Collection {
  final String name;
  final List<SubCollection>? subCollections;

  Collection({required this.name, this.subCollections});

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      name: json['name'],
      subCollections: json['sub_collections'] != null
          ? List<SubCollection>.from(
              json['sub_collections'].map((x) => SubCollection.fromJson(x)))
          : null,
    );
  }
}

class SubCollection {
  final String id;
  final String name;

  SubCollection({required this.id, required this.name});

  factory SubCollection.fromJson(Map<String, dynamic> json) {
    return SubCollection(
      id: json['id'], // รับค่า id จาก JSON
      name: json['name'],
    );
  }
}
