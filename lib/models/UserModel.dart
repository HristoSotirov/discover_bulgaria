import 'enums/rank_type.dart';
import 'enums/user_type.dart';

class UserModel {
  final String? id; // 👈 вече е nullable
  final DateTime createdAt;
  final String? imageUrl;
  final String name;
  final String email;
  final String password;
  final int points;
  final int streaks;
  final RankType? rankType;
  final UserType userType;
  final DateTime birthDate;
  final bool isDailyQuizDone;

  UserModel({
    this.id,
    required this.createdAt,
    this.imageUrl,
    required this.name,
    required this.email,
    required this.password,
    required this.points,
    required this.streaks,
    this.rankType,
    required this.userType,
    required this.birthDate,
    required this.isDailyQuizDone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'], // може да дойде от Supabase
      createdAt: DateTime.parse(json['created_at']),
      imageUrl: json['image_url'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      points: json['points'],
      streaks: json['streaks'],
      rankType: json['rank_type'] != null ? RankType.fromString(json['rank_type']) : null,
      userType: UserType.fromString(json['user_type']),
      birthDate: DateTime.parse(json['birth_date']),
      isDailyQuizDone: json['is_daily_quiz_done'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'created_at': createdAt.toIso8601String(),
      'image_url': imageUrl,
      'name': name,
      'email': email,
      'password': password,
      'points': points,
      'streak': streaks,
      'rank_type': rankType?.toShortString(),
      'user_type': userType.toShortString(),
      'birth_date': birthDate.toIso8601String(),
      'is_daily_quiz_done': isDailyQuizDone,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }
}
