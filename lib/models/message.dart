import 'package:equatable/equatable.dart';
import 'user.dart';

enum MessageType {
  text,
  image,
  video,
  file,
  contact,
  location,
  voiceMessage,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  read,
  failed,
}

class Message extends Equatable {
  final String id;
  final String chatId;
  final User sender;
  final MessageType type;
  final String content;
  final String? mediaUrl;
  final String? fileName;
  final int? fileSize;
  final Duration? voiceDuration;
  final double? latitude;
  final double? longitude;
  final String? locationName;
  final MessageStatus status;
  final DateTime timestamp;
  final DateTime? editedAt;
  final bool isReply;
  final Message? replyTo;
  final List<String>? mentions;
  final Map<String, List<String>>? reactions; // emoji -> list of user IDs

  const Message({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.type,
    required this.content,
    this.mediaUrl,
    this.fileName,
    this.fileSize,
    this.voiceDuration,
    this.latitude,
    this.longitude,
    this.locationName,
    this.status = MessageStatus.sent,
    required this.timestamp,
    this.editedAt,
    this.isReply = false,
    this.replyTo,
    this.mentions,
    this.reactions,
  });

  Message copyWith({
    String? id,
    String? chatId,
    User? sender,
    MessageType? type,
    String? content,
    String? mediaUrl,
    String? fileName,
    int? fileSize,
    Duration? voiceDuration,
    double? latitude,
    double? longitude,
    String? locationName,
    MessageStatus? status,
    DateTime? timestamp,
    DateTime? editedAt,
    bool? isReply,
    Message? replyTo,
    List<String>? mentions,
    Map<String, List<String>>? reactions,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      content: content ?? this.content,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      voiceDuration: voiceDuration ?? this.voiceDuration,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      editedAt: editedAt ?? this.editedAt,
      isReply: isReply ?? this.isReply,
      replyTo: replyTo ?? this.replyTo,
      mentions: mentions ?? this.mentions,
      reactions: reactions ?? this.reactions,
    );
  }

  @override
  List<Object?> get props => [
        id,
        chatId,
        sender,
        type,
        content,
        mediaUrl,
        fileName,
        fileSize,
        voiceDuration,
        latitude,
        longitude,
        locationName,
        status,
        timestamp,
        editedAt,
        isReply,
        replyTo,
        mentions,
        reactions,
      ];

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      chatId: json['chat_id'] as String,
      sender: User.fromJson(json['sender'] as Map<String, dynamic>),
      type: MessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MessageType.text,
      ),
      content: json['content'] as String,
      mediaUrl: json['media_url'] as String?,
      fileName: json['file_name'] as String?,
      fileSize: json['file_size'] as int?,
      voiceDuration: json['voice_duration'] != null
          ? Duration(milliseconds: json['voice_duration'] as int)
          : null,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
      locationName: json['location_name'] as String?,
      status: MessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      editedAt: json['edited_at'] != null
          ? DateTime.parse(json['edited_at'] as String)
          : null,
      isReply: json['is_reply'] as bool? ?? false,
      replyTo: json['reply_to'] != null
          ? Message.fromJson(json['reply_to'] as Map<String, dynamic>)
          : null,
      mentions: json['mentions'] != null
          ? List<String>.from(json['mentions'] as List)
          : null,
      reactions: json['reactions'] != null
          ? Map<String, List<String>>.from(
              (json['reactions'] as Map<String, dynamic>).map(
                (key, value) => MapEntry(
                  key,
                  List<String>.from(value as List),
                ),
              ),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chat_id': chatId,
      'sender': sender.toJson(),
      'type': type.name,
      'content': content,
      'media_url': mediaUrl,
      'file_name': fileName,
      'file_size': fileSize,
      'voice_duration': voiceDuration?.inMilliseconds,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'status': status.name,
      'timestamp': timestamp.toIso8601String(),
      'edited_at': editedAt?.toIso8601String(),
      'is_reply': isReply,
      'reply_to': replyTo?.toJson(),
      'mentions': mentions,
      'reactions': reactions,
    };
  }
}
