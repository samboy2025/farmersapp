import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String phoneNumber;
  final String name;
  final String? profilePicture;
  final String? about;
  final String? email;
  final DateTime lastSeen;
  final bool isOnline;
  final bool isVerified;

  const User({
    required this.id,
    required this.phoneNumber,
    required this.name,
    this.profilePicture,
    this.about,
    this.email,
    required this.lastSeen,
    this.isOnline = false,
    this.isVerified = false,
  });

  User copyWith({
    String? id,
    String? phoneNumber,
    String? name,
    String? profilePicture,
    String? about,
    String? email,
    DateTime? lastSeen,
    bool? isOnline,
    bool? isVerified,
  }) {
    return User(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      about: about ?? this.about,
      email: email ?? this.email,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  List<Object?> get props => [
        id,
        phoneNumber,
        name,
        profilePicture,
        about,
        email,
        lastSeen,
        isOnline,
        isVerified,
      ];

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String,
      name: json['name'] as String,
      profilePicture: json['profile_picture'] as String?,
      about: json['about'] as String?,
      email: json['email'] as String?,
      lastSeen: DateTime.parse(json['last_seen'] as String),
      isOnline: json['is_online'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'name': name,
      'profile_picture': profilePicture,
      'about': about,
      'email': email,
      'last_seen': lastSeen.toIso8601String(),
      'is_online': isOnline,
      'is_verified': isVerified,
    };
  }
}
