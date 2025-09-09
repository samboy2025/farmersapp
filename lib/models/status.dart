import 'package:equatable/equatable.dart';
import 'user.dart';

enum StatusType { image, video, text }

enum StatusPrivacy { public, contactsOnly, custom }

class Status extends Equatable {
  final String id;
  final User author;
  final String? mediaUrl;
  final StatusType type;
  final String? caption;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool viewed;
  final StatusPrivacy privacy;
  final List<String> allowedViewers;
  final int viewCount;
  final List<StatusReaction> reactions;
  final String? thumbnailUrl;
  final Duration? duration;
  final Map<String, dynamic>? metadata;

  const Status({
    required this.id,
    required this.author,
    this.mediaUrl,
    required this.type,
    this.caption,
    required this.createdAt,
    required this.expiresAt,
    this.viewed = false,
    this.privacy = StatusPrivacy.public,
    this.allowedViewers = const [],
    this.viewCount = 0,
    this.reactions = const [],
    this.thumbnailUrl,
    this.duration,
    this.metadata,
  });

  Status copyWith({
    bool? viewed,
    int? viewCount,
    List<StatusReaction>? reactions,
    List<String>? allowedViewers,
    StatusPrivacy? privacy,
  }) => Status(
        id: id,
        author: author,
        mediaUrl: mediaUrl,
        type: type,
        caption: caption,
        createdAt: createdAt,
        expiresAt: expiresAt,
        viewed: viewed ?? this.viewed,
        viewCount: viewCount ?? this.viewCount,
        reactions: reactions ?? this.reactions,
        allowedViewers: allowedViewers ?? this.allowedViewers,
        privacy: privacy ?? this.privacy,
        thumbnailUrl: thumbnailUrl,
        duration: duration,
        metadata: metadata,
      );

  // Helper getters
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isActive => !isExpired;
  bool get hasMedia => mediaUrl != null;
  bool get isVideo => type == StatusType.video;
  bool get isImage => type == StatusType.image;
  bool get isText => type == StatusType.text;

  // Convenience getters for backward compatibility
  String get userId => author.id;
  String? get content => caption;
  
  // Time-related helpers
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  // Privacy helpers
  bool isVisibleTo(User user) {
    if (privacy == StatusPrivacy.public) return true;
    if (privacy == StatusPrivacy.contactsOnly) return true;
    if (privacy == StatusPrivacy.custom) {
      return allowedViewers.contains(user.id);
    }
    return false;
  }

  // JSON serialization
  factory Status.fromJson(Map<String, dynamic> json) {
    return Status(
      id: json['id'] as String,
      author: User.fromJson(json['author'] as Map<String, dynamic>),
      mediaUrl: json['media_url'] as String?,
      type: StatusType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StatusType.image,
      ),
      caption: json['caption'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      viewed: json['viewed'] as bool? ?? false,
      privacy: StatusPrivacy.values.firstWhere(
        (e) => e.name == json['privacy'],
        orElse: () => StatusPrivacy.public,
      ),
      allowedViewers: (json['allowed_viewers'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      viewCount: json['view_count'] as int? ?? 0,
      reactions: (json['reactions'] as List<dynamic>?)
          ?.map((e) => StatusReaction.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      thumbnailUrl: json['thumbnail_url'] as String?,
      duration: json['duration'] != null 
          ? Duration(seconds: json['duration'] as int)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author.toJson(),
      'media_url': mediaUrl,
      'type': type.name,
      'caption': caption,
      'created_at': createdAt.toIso8601String(),
      'expires_at': expiresAt.toIso8601String(),
      'viewed': viewed,
      'privacy': privacy.name,
      'allowed_viewers': allowedViewers,
      'view_count': viewCount,
      'reactions': reactions.map((e) => e.toJson()).toList(),
      'thumbnail_url': thumbnailUrl,
      'duration': duration?.inSeconds,
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
        id, 
        author, 
        mediaUrl, 
        type, 
        caption, 
        createdAt, 
        expiresAt, 
        viewed, 
        privacy,
        allowedViewers,
        viewCount,
        reactions,
        thumbnailUrl,
        duration,
        metadata,
      ];
}

class StatusReaction extends Equatable {
  final String id;
  final User user;
  final String emoji;
  final DateTime timestamp;

  const StatusReaction({
    required this.id,
    required this.user,
    required this.emoji,
    required this.timestamp,
  });

  factory StatusReaction.fromJson(Map<String, dynamic> json) {
    return StatusReaction(
      id: json['id'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      emoji: json['emoji'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'emoji': emoji,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, user, emoji, timestamp];
}

class StatusDraft extends Equatable {
  final String? id;
  final String? mediaPath;
  final StatusType type;
  final String? caption;
  final DateTime createdAt;
  final StatusPrivacy privacy;
  final List<String> allowedViewers;

  const StatusDraft({
    this.id,
    this.mediaPath,
    required this.type,
    this.caption,
    required this.createdAt,
    this.privacy = StatusPrivacy.public,
    this.allowedViewers = const [],
  });

  @override
  List<Object?> get props => [
        id, 
        mediaPath, 
        type, 
        caption, 
        createdAt, 
        privacy, 
        allowedViewers,
      ];
}
