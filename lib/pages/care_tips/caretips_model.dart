class CareTip {
  String id;
  String title;
  String secondTitle;
  List<String> images;
  String detailedInfo;
  String thumbnail; // New field for the thumbnail image
  String subcategory;

  CareTip({
    required this.id,
    required this.title,
    required this.secondTitle,
    required this.images,
    required this.detailedInfo,
    required this.thumbnail, // Initialize the new field
    required this.subcategory,
  });

  // Update fromMap and toMap methods to include the thumbnail
  factory CareTip.fromMap(Map<String, dynamic> map) {
    return CareTip(
      id: map['id'],
      title: map['title'],
      secondTitle: map['secondTitle'],
      images: List<String>.from(map['images']),
      detailedInfo: map['detailedInfo'],
      thumbnail: map['thumbnail'], // Include the new field
      subcategory: map['subcategory'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'secondTitle': secondTitle,
      'images': images,
      'detailedInfo': detailedInfo,
      'thumbnail': thumbnail, // Include the new field
      'subcategory': subcategory,
    };
  }
}

class EvacuationCareTip {
  String id;
  String title;
  String secondTitle;
  List<String> images;
  String detailedInfo;
  String thumbnail; // New field for the thumbnail image

  EvacuationCareTip({
    required this.id,
    required this.title,
    required this.secondTitle,
    required this.images,
    required this.detailedInfo,
    required this.thumbnail, // Initialize the new field
  });

  // Update fromMap and toMap methods to include the thumbnail
  factory EvacuationCareTip.fromMap(Map<String, dynamic> map) {
    return EvacuationCareTip(
      id: map['id'],
      title: map['title'],
      secondTitle: map['secondTitle'],
      images: List<String>.from(map['images']),
      detailedInfo: map['detailedInfo'],
      thumbnail: map['thumbnail'], // Include the new field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'secondTitle': secondTitle,
      'images': images,
      'detailedInfo': detailedInfo,
      'thumbnail': thumbnail, // Include the new field
    };
  }
}

class DisasterCareTip {
  String id;
  String title;
  String secondTitle;
  List<String> images;
  String detailedInfo;
  String thumbnail; // New field for the thumbnail image

  DisasterCareTip({
    required this.id,
    required this.title,
    required this.secondTitle,
    required this.images,
    required this.detailedInfo,
    required this.thumbnail, // Initialize the new field
  });

  // Update fromMap and toMap methods to include the thumbnail
  factory DisasterCareTip.fromMap(Map<String, dynamic> map) {
    return DisasterCareTip(
      id: map['id'],
      title: map['title'],
      secondTitle: map['secondTitle'],
      images: List<String>.from(map['images']),
      detailedInfo: map['detailedInfo'],
      thumbnail: map['thumbnail'], // Include the new field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'secondTitle': secondTitle,
      'images': images,
      'detailedInfo': detailedInfo,
      'thumbnail': thumbnail, // Include the new field
    };
  }
}
