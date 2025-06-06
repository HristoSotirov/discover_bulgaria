class LandmarkModel {
  final String? id;
  final String imageUrl;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final List<String> questions;

  LandmarkModel({
    this.id,
    required this.imageUrl,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.questions,
  });

  factory LandmarkModel.fromJson(Map<String, dynamic> json) {
    return LandmarkModel(
      id: json['id'],
      imageUrl: json['image_url'],
      name: json['name'],
      description: json['description'],
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      questions: List<String>.from(json['questions'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_url': imageUrl,
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'questions': questions,
    };
  }

}
