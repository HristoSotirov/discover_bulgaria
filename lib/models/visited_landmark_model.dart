class VisitedLandmarkModel {
  final String? id;
  final String userId;
  final String landmarkId;
  final DateTime date;

  VisitedLandmarkModel({
    this.id,
    required this.userId,
    required this.landmarkId,
    required this.date,
  });

  factory VisitedLandmarkModel.fromJson(Map<String, dynamic> json) {
    return VisitedLandmarkModel(
      id: json['id'],
      userId: json['user_id'],
      landmarkId: json['landmark_id'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'landmark_id': landmarkId,
      'date': date.toIso8601String(),
    };
  }
}