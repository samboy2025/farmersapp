import 'package:equatable/equatable.dart';
import 'user.dart';

enum CallType {
  voice,
  video,
}

enum CallStatus {
  initial,
  dialing,
  incoming,
  connecting,
  connected,
  ended,
  failed,
  rejected,
  missed,
}

class Call extends Equatable {
  final String id;
  final String callerId;
  final String receiverId;
  final CallType type;
  final CallStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration;
  final bool isIncoming;
  final String? sessionId;

  const Call({
    required this.id,
    required this.callerId,
    required this.receiverId,
    required this.type,
    required this.status,
    required this.startTime,
    this.endTime,
    this.duration,
    required this.isIncoming,
    this.sessionId,
  });

  Call copyWith({
    String? id,
    String? callerId,
    String? receiverId,
    CallType? type,
    CallStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    bool? isIncoming,
    String? sessionId,
  }) {
    return Call(
      id: id ?? this.id,
      callerId: callerId ?? this.callerId,
      receiverId: receiverId ?? this.receiverId,
      type: type ?? this.type,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      isIncoming: isIncoming ?? this.isIncoming,
      sessionId: sessionId ?? this.sessionId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        callerId,
        receiverId,
        type,
        status,
        startTime,
        endTime,
        duration,
        isIncoming,
        sessionId,
      ];

  factory Call.fromJson(Map<String, dynamic> json) {
    return Call(
      id: json['id'] as String,
      callerId: json['caller_id'] as String,
      receiverId: json['receiver_id'] as String,
      type: CallType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CallType.voice,
      ),
      status: CallStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => CallStatus.initial,
      ),
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      duration: json['duration'] != null
          ? Duration(milliseconds: json['duration'] as int)
          : null,
      isIncoming: json['is_incoming'] as bool,
      sessionId: json['session_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caller_id': callerId,
      'receiver_id': receiverId,
      'type': type.name,
      'status': status.name,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration': duration?.inMilliseconds,
      'is_incoming': isIncoming,
      'session_id': sessionId,
    };
  }
}
