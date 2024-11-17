class Province {
  final String name;
  final List<District>? districts;

  Province({required this.name, this.districts});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      name: json['name'],
      districts: json['districts'] != null
          ? List<District>.from(
              json['districts'].map((x) => District.fromJson(x)))
          : null,
    );
  }
}

class District {
  final String name;
  final List<SubDistrict>? subDistricts;

  District({required this.name, this.subDistricts});

  factory District.fromJson(Map<String, dynamic> json) {
    return District(
      name: json['name'],
      subDistricts: json['sub_districts'] != null
          ? List<SubDistrict>.from(
              json['sub_districts'].map((x) => SubDistrict.fromJson(x)))
          : null,
    );
  }
}

class SubDistrict {
  final int id;
  final String name;

  SubDistrict({required this.id, required this.name});

  factory SubDistrict.fromJson(Map<String, dynamic> json) {
    return SubDistrict(
      id: json['id'], // รับค่า id จาก JSON
      name: json['name'],
    );
  }
}
