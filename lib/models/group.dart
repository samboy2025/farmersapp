import 'package:equatable/equatable.dart';
import 'user.dart';
import 'message.dart';

class Group extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? groupPicture;
  final List<User> members;
  final List<User> admins;
  final User createdBy;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime lastActivity;
  final DateTime createdAt;
  final bool isPrivate;
  final bool isAdminOnly;
  final int maxMembers;

  const Group({
    required this.id,
    required this.name,
    this.description,
    this.groupPicture,
    required this.members,
    required this.admins,
    required this.createdBy,
    this.lastMessage,
    this.unreadCount = 0,
    required this.lastActivity,
    required this.createdAt,
    this.isPrivate = false,
    this.isAdminOnly = false,
    this.maxMembers = 256,
  });

  Group copyWith({
    String? id,
    String? name,
    String? description,
    String? groupPicture,
    List<User>? members,
    List<User>? admins,
    User? createdBy,
    Message? lastMessage,
    int? unreadCount,
    DateTime? lastActivity,
    DateTime? createdAt,
    bool? isPrivate,
    bool? isAdminOnly,
    int? maxMembers,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      groupPicture: groupPicture ?? this.groupPicture,
      members: members ?? this.members,
      admins: admins ?? this.admins,
      createdBy: createdBy ?? this.createdBy,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      lastActivity: lastActivity ?? this.lastActivity,
      createdAt: createdAt ?? this.createdAt,
      isPrivate: isPrivate ?? this.isPrivate,
      isAdminOnly: isAdminOnly ?? this.isAdminOnly,
      maxMembers: maxMembers ?? this.maxMembers,
    );
  }

  bool get isAdmin => admins.isNotEmpty;
  bool get canAddMembers => isAdmin || !isAdminOnly;
  bool get canSendMessages => !isAdminOnly || isAdmin;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        groupPicture,
        members,
        admins,
        createdBy,
        lastMessage,
        unreadCount,
        lastActivity,
        createdAt,
        isPrivate,
        isAdminOnly,
        maxMembers,
      ];

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      groupPicture: json['group_picture'] as String?,
      members: (json['members'] as List)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      admins: (json['admins'] as List)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdBy: User.fromJson(json['created_by'] as Map<String, dynamic>),
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      lastActivity: DateTime.parse(json['last_activity'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      isPrivate: json['is_private'] as bool? ?? false,
      isAdminOnly: json['is_admin_only'] as bool? ?? false,
      maxMembers: json['max_members'] as int? ?? 256,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'group_picture': groupPicture,
      'members': members.map((e) => e.toJson()).toList(),
      'admins': admins.map((e) => e.toJson()).toList(),
      'created_by': createdBy.toJson(),
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'last_activity': lastActivity.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'is_private': isPrivate,
      'is_admin_only': isAdminOnly,
      'max_members': maxMembers,
    };
  }
}
