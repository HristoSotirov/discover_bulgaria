import 'enums/user_type.dart';

class UserModel {
  final String? id; // 👈 вече е nullable
  final DateTime createdAt;
  final String? imageUrl;
  final String name;
  final String email;
  final String password;
  final int points;
  final int streak;
  final String rankType;
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
    required this.streak,
    required this.rankType,
    required this.userType,
    required this.birthDate,
    required this.isDailyQuizDone,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('Received JSON: $json'); // 👈 ВАЖНО

    return UserModel(
      id: json['id'],
      createdAt: DateTime.parse(json['created_at']),
      imageUrl: json['image_url'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      points: json['points'] ?? 0,
      streak: json['streak'] ?? 0,
      rankType: json['rank_type'],
      userType: json['user_type'] != null ? UserType.fromString(json['user_type']) : UserType.user,
      birthDate: DateTime.parse(json['birth_date']),
      isDailyQuizDone: json['is_daily_quiz_done'] ?? false,
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
      'streak': streak,
      'rank_type': rankType,
      'user_type': userType.toShortString(),
      'birth_date': birthDate.toIso8601String(),
      'is_daily_quiz_done': isDailyQuizDone,
    };

    if (id != null) {
      map['id'] = id;
    }

    return map;
  }

  UserModel copyWith({
    String? id,
    DateTime? createdAt,
    String? imageUrl,
    String? name,
    String? email,
    String? password,
    int? points,
    int? streaks,
    String? rankType,
    UserType? userType,
    DateTime? birthDate,
    bool? isDailyQuizDone,
  }) {
    return UserModel(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      points: points ?? this.points,
      streak: streaks ?? this.streak,
      rankType: rankType ?? this.rankType,
      userType: userType ?? this.userType,
      birthDate: birthDate ?? this.birthDate,
      isDailyQuizDone: isDailyQuizDone ?? this.isDailyQuizDone,
    );
  }
}

