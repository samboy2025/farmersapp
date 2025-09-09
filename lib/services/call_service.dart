import 'dart:async';
import 'package:flutter/material.dart';
import '../models/call.dart';
import '../models/user.dart';
import '../models/chat.dart';
import '../repositories/call_repository.dart';
import '../services/mock_data_service.dart';

class CallService {
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  final CallRepository _callRepository = CallRepository();
  final StreamController<Call> _incomingCallController = StreamController<Call>.broadcast();
  final StreamController<Call> _callEndedController = StreamController<Call>.broadcast();
  
  // Current call state
  Call? _currentCall;
  bool _isInitialized = false;

  // Getters
  Stream<Call> get incomingCallStream => _incomingCallController.stream;
  Stream<Call> get callEndedStream => _callEndedController.stream;
  Call? get currentCall => _currentCall;
  bool get isInitialized => _isInitialized;

  /// Initialize the call service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _callRepository.initialize();
      
      // Listen to repository events
      _callRepository.incomingCallStream.listen((call) {
        _handleIncomingCall(call);
      });
      
      _callRepository.callStateStream.listen((data) {
        _handleCallStateChange(data);
      });
      
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize CallService: $e');
      rethrow;
    }
  }

  /// Handle incoming call from repository
  void _handleIncomingCall(Call call) {
    _currentCall = call;
    _incomingCallController.add(call);
  }

  /// Handle call state changes from repository
  void _handleCallStateChange(Map<String, dynamic> data) {
    final type = data['type'] as String;
    final callId = data['callId'] as String;
    
    switch (type) {
      case 'status-change':
        final status = data['status'] as CallStatus;
        if (status == CallStatus.ended) {
          _handleCallEnded(callId);
        }
        break;
    }
  }

  /// Handle call ended
  void _handleCallEnded(String callId) {
    if (_currentCall?.id == callId) {
      final endedCall = _currentCall!;
      _currentCall = null;
      _callEndedController.add(endedCall);
    }
  }

  /// Make a call to a user
  Future<Call?> makeCall(User receiver, CallType type) async {
    if (!_isInitialized) {
      throw Exception('CallService not initialized');
    }

    try {
      final call = await _callRepository.initiateCall(receiver.id, type);
      _currentCall = call;
      return call;
    } catch (e) {
      print('Failed to make call: $e');
      return null;
    }
  }

  /// Make a call from chat
  Future<Call?> makeCallFromChat(Chat chat, CallType type) async {
    final currentUser = MockDataService.currentUser;
    final receiver = chat.participants.firstWhere((user) => user.id != currentUser.id);
    return makeCall(receiver, type);
  }

  /// Answer an incoming call
  Future<bool> answerCall(String callId) async {
    if (!_isInitialized || _currentCall == null) {
      return false;
    }

    try {
      await _callRepository.answerCall(callId);
      return true;
    } catch (e) {
      print('Failed to answer call: $e');
      return false;
    }
  }

  /// Reject an incoming call
  Future<bool> rejectCall(String callId) async {
    if (!_isInitialized || _currentCall == null) {
      return false;
    }

    try {
      await _callRepository.rejectCall(callId);
      _currentCall = null;
      return true;
    } catch (e) {
      print('Failed to reject call: $e');
      return false;
    }
  }

  /// End current call
  Future<bool> endCall() async {
    if (!_isInitialized || _currentCall == null) {
      return false;
    }

    try {
      await _callRepository.endCall(_currentCall!.id);
      _currentCall = null;
      return true;
    } catch (e) {
      print('Failed to end call: $e');
      return false;
    }
  }

  /// Toggle mute state
  Future<void> toggleMute() async {
    if (_isInitialized) {
      await _callRepository.toggleMute();
    }
  }

  /// Toggle video state
  Future<void> toggleVideo() async {
    if (_isInitialized) {
      await _callRepository.toggleVideo();
    }
  }

  /// Switch camera
  Future<void> switchCamera() async {
    if (_isInitialized) {
      await _callRepository.switchCamera();
    }
  }

  /// Get call history for a user
  List<Call> getCallHistory(String userId) {
    // In a real app, this would fetch from local database or API
    // For now, return mock data
    return [
      Call(
        id: '1',
        callerId: userId,
        receiverId: 'other_user_id',
        type: CallType.voice,
        status: CallStatus.ended,
        startTime: DateTime.now().subtract(const Duration(hours: 2)),
        endTime: DateTime.now().subtract(const Duration(hours: 1, minutes: 55)),
        duration: const Duration(minutes: 5),
        isIncoming: false,
      ),
      Call(
        id: '2',
        callerId: 'other_user_id',
        receiverId: userId,
        type: CallType.video,
        status: CallStatus.ended,
        startTime: DateTime.now().subtract(const Duration(days: 1)),
        endTime: DateTime.now().subtract(const Duration(days: 1, minutes: 45)),
        duration: const Duration(minutes: 15),
        isIncoming: true,
      ),
    ];
  }

  /// Check if user is in a call
  bool isUserInCall(String userId) {
    return _currentCall != null && 
           (_currentCall!.callerId == userId || _currentCall!.receiverId == userId);
  }

  /// Get call status for a user
  CallStatus? getUserCallStatus(String userId) {
    if (_currentCall != null && 
        (_currentCall!.callerId == userId || _currentCall!.receiverId == userId)) {
      return _currentCall!.status;
    }
    return null;
  }

  /// Show incoming call notification
  void showIncomingCallNotification(BuildContext context, Call call, User caller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Incoming ${call.type == CallType.video ? 'Video' : 'Voice'} Call'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: caller.profilePicture != null
                  ? NetworkImage(caller.profilePicture!)
                  : null,
              child: caller.profilePicture == null
                  ? Text(
                      caller.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(fontSize: 20),
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            Text(caller.name),
            Text(caller.phoneNumber),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              rejectCall(call.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Decline'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              answerCall(call.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Answer'),
          ),
        ],
      ),
    );
  }

  /// Show call ended notification
  void showCallEndedNotification(BuildContext context, Call call, Duration duration) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Call ended - Duration: ${_formatDuration(duration)}'),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Navigate to call history or show call details
          },
        ),
      ),
    );
  }

  /// Format duration for display
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  /// Dispose resources
  void dispose() {
    _incomingCallController.close();
    _callEndedController.close();
    _callRepository.dispose();
    _isInitialized = false;
  }
}
