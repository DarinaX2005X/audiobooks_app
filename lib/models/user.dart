class User {
  final String id;
  final String email;
  final String username;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Favorite>? favorites;
  final List<Progress>? progress;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.createdAt,
    required this.updatedAt,
    this.favorites,
    this.progress,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      favorites: json['favorites'] != null
          ? (json['favorites'] as List<dynamic>)
              .map((e) => Favorite.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
      progress: json['progress'] != null
          ? (json['progress'] as List<dynamic>)
              .map((e) => Progress.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      if (favorites != null) 'favorites': favorites!.map((e) => e.toJson()).toList(),
      if (progress != null) 'progress': progress!.map((e) => e.toJson()).toList(),
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Favorite>? favorites,
    List<Progress>? progress,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      favorites: favorites ?? this.favorites,
      progress: progress ?? this.progress,
    );
  }
}

class Favorite {
  final String id;
  final String userId;
  final String audiobookId;
  final DateTime createdAt;

  Favorite({
    required this.id,
    required this.userId,
    required this.audiobookId,
    required this.createdAt,
  });

  factory Favorite.fromJson(Map<String, dynamic> json) {
    return Favorite(
      id: json['id'] as String,
      userId: json['userId'] as String,
      audiobookId: json['audiobookId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'audiobookId': audiobookId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Progress {
  final String id;
  final String userId;
  final String audiobookId;
  final int positionSec;
  final DateTime updatedAt;

  Progress({
    required this.id,
    required this.userId,
    required this.audiobookId,
    required this.positionSec,
    required this.updatedAt,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['id'] as String,
      userId: json['userId'] as String,
      audiobookId: json['audiobookId'] as String,
      positionSec: json['positionSec'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'audiobookId': audiobookId,
      'positionSec': positionSec,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
} 