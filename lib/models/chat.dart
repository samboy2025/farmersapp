import 'package:equatable/equatable.dart';
import 'user.dart';
import 'message.dart';

class Chat extends Equatable {
  final String id;
  final String name;
  final String? groupPicture;
  final List<User> participants;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime lastActivity;
  final bool isGroup;
  final bool isPinned;
  final bool isMuted;
  final bool isArchived;
  final DateTime createdAt;

  const Chat({
    required this.id,
    required this.name,
    this.groupPicture,
    required this.participants,
    this.lastMessage,
    this.unreadCount = 0,
    required this.lastActivity,
    this.isGroup = false,
    this.isPinned = false,
    this.isMuted = false,
    this.isArchived = false,
    required this.createdAt,
  });

  Chat copyWith({
    String? id,
    String? name,
    String? groupPicture,
    List<User>? participants,
    Message? lastMessage,
    int? unreadCount,
    DateTime? lastActivity,
    bool? isGroup,
    bool? isPinned,
    bool? isMuted,
    bool? isArchived,
    DateTime? createdAt,
  }) {
    return Chat(
      id: id ?? this.id,
      name: name ?? this.name,
      groupPicture: groupPicture ?? this.groupPicture,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
      lastActivity: lastActivity ?? this.lastActivity,
      isGroup: isGroup ?? this.isGroup,
      isPinned: isPinned ?? this.isPinned,
      isMuted: isMuted ?? this.isMuted,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        groupPicture,
        participants,
        lastMessage,
        unreadCount,
        lastActivity,
        isGroup,
        isPinned,
        isMuted,
        isArchived,
        createdAt,
      ];

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'] as String,
      name: json['name'] as String,
      groupPicture: json['group_picture'] as String?,
      participants: (json['participants'] as List)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      unreadCount: json['unread_count'] as int? ?? 0,
      lastActivity: DateTime.parse(json['last_activity'] as String),
      isGroup: json['is_group'] as bool? ?? false,
      isPinned: json['is_pinned'] as bool? ?? false,
      isMuted: json['is_muted'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'group_picture': groupPicture,
      'participants': participants.map((e) => e.toJson()).toList(),
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
      'last_activity': lastActivity.toIso8601String(),
      'is_group': isGroup,
      'is_pinned': isPinned,
      'is_muted': isMuted,
      'is_archived': isArchived,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
