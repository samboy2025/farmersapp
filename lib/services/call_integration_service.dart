import 'dart:async';
import 'package:flutter/material.dart';
import '../models/call.dart';
import '../models/user.dart';
import '../models/chat.dart';
import '../services/call_service.dart';
import '../services/mock_data_service.dart';

/// Service that integrates call functionality with the rest of the app
class CallIntegrationService {
  static final CallIntegrationService _instance = CallIntegrationService._internal();
  factory CallIntegrationService() => _instance;
  CallIntegrationService._internal();

  final CallService _callService = CallService();
  final StreamController<Call> _callStartedController = StreamController<Call>.broadcast();
  final StreamController<Call> _callEndedController = StreamController<Call>.broadcast();
  
  // Streams for app-wide call events
  Stream<Call> get callStartedStream => _callStartedController.stream;
  Stream<Call> get callEndedStream => _callEndedController.stream;

  /// Initialize the integration service
  Future<void> initialize() async {
    await _callService.initialize();
    
    // Listen to call service events
    _callService.incomingCallStream.listen((call) {
      _handleIncomingCall(call);
    });
    
    _callService.callEndedStream.listen((call) {
      _handleCallEnded(call);
    });
  }

  /// Handle incoming call and show notification
  void _handleIncomingCall(Call call) {
    final caller = MockDataService.getUserById(call.callerId);
    if (caller != null) {
      _callStartedController.add(call);
      _showIncomingCallNotification(call, caller);
    }
  }

  /// Handle call ended and update app state
  void _handleCallEnded(Call call) {
    _callEndedController.add(call);
    _updateCallHistory(call);
    _showCallEndedNotification(call);
  }

  /// Show incoming call notification
  void _showIncomingCallNotification(Call call, User caller) {
    // In a real app, this would show a system notification
    // For now, we'll just print to console
    print('Incoming ${call.type.name} call from ${caller.name}');
  }

  /// Show call ended notification
  void _showCallEndedNotification(Call call) {
    // In a real app, this would show a system notification
    print('Call ended: ${call.id}');
  }

  /// Update call history in the app
  void _updateCallHistory(Call call) {
    // In a real app, this would update local database or send to server
    print('Updating call history for call: ${call.id}');
  }

  /// Make a call from chat screen
  Future<void> makeCallFromChat(BuildContext context, Chat chat, CallType type) async {
    final currentUser = MockDataService.currentUser;
    final receiver = chat.participants.firstWhere((user) => user.id != currentUser.id);
    
    await makeCall(context, receiver, type);
  }

  /// Make a call to a specific user
  Future<void> makeCall(BuildContext context, User receiver, CallType type) async {
    // Check if user is already in a call
    if (_callService.isUserInCall(receiver.id)) {
      _showUserBusyDialog(context, receiver);
      return;
    }

    // Check if current user is in a call
    if (_callService.isUserInCall(MockDataService.currentUser.id)) {
      _showUserInCallDialog(context);
      return;
    }

    try {
      final call = await _callService.makeCall(receiver, type);
      if (call != null) {
        _callStartedController.add(call);
        _navigateToCallScreen(context, call, receiver, type);
      }
    } catch (e) {
      _showCallErrorDialog(context, 'Failed to initiate call: $e');
    }
  }

  /// Navigate to call screen
  void _navigateToCallScreen(BuildContext context, Call call, User receiver, CallType type) {
    final chat = _createChatFromUser(receiver);
    
    Navigator.pushNamed(
      context,
      '/call',
      arguments: {
        'chat': chat,
        'isVideo': type == CallType.video,
        'isIncoming': false,
      },
    );
  }

  /// Create temporary chat for call navigation
  Chat _createChatFromUser(User user) {
    return Chat(
      id: 'temp_${user.id}',
      name: user.name,
      participants: [MockDataService.currentUser, user],
      lastMessage: null,
      unreadCount: 0,
      lastActivity: DateTime.now(),
      isGroup: false,
      isPinned: false,
      createdAt: DateTime.now(),
    );
  }

  /// Show dialog when user is busy
  void _showUserBusyDialog(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Busy'),
        content: Text('${user.name} is currently in another call.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show dialog when current user is in a call
  void _showUserInCallDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Already in Call'),
        content: const Text('You are already in a call. Please end the current call first.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show call error dialog
  void _showCallErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Call Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Get call status for display in UI
  String getCallStatusText(CallStatus status) {
    switch (status) {
      case CallStatus.dialing:
        return 'Calling...';
      case CallStatus.incoming:
        return 'Incoming call...';
      case CallStatus.connecting:
        return 'Connecting...';
      case CallStatus.connected:
        return 'Connected';
      case CallStatus.ended:
        return 'Call ended';
      case CallStatus.failed:
        return 'Call failed';
      case CallStatus.rejected:
        return 'Call rejected';
      case CallStatus.missed:
        return 'Missed call';
      default:
        return 'Unknown';
    }
  }

  /// Get call status color for UI
  Color getCallStatusColor(CallStatus status) {
    switch (status) {
      case CallStatus.connected:
        return Colors.green;
      case CallStatus.dialing:
      case CallStatus.connecting:
        return Colors.orange;
      case CallStatus.incoming:
        return Colors.blue;
      case CallStatus.ended:
        return Colors.grey;
      case CallStatus.failed:
      case CallStatus.rejected:
      case CallStatus.missed:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Check if user can make calls
  bool canMakeCall(String userId) {
    return !_callService.isUserInCall(userId);
  }

  /// Get current call information
  Call? getCurrentCall() {
    return _callService.currentCall;
  }

  /// End current call
  Future<bool> endCurrentCall() async {
    return await _callService.endCall();
  }

  /// Toggle mute for current call
  Future<void> toggleMute() async {
    await _callService.toggleMute();
  }

  /// Toggle video for current call
  Future<void> toggleVideo() async {
    await _callService.toggleVideo();
  }

  /// Switch camera for current call
  Future<void> switchCamera() async {
    await _callService.switchCamera();
  }

  /// Get call history for a user
  List<Call> getCallHistory(String userId) {
    return _callService.getCallHistory(userId);
  }

  /// Add call buttons to chat header
  Widget buildCallButtons(BuildContext context, Chat chat, {bool showLabels = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Voice call button
        _buildCallButton(
          icon: Icons.call,
          label: showLabels ? 'Call' : null,
          color: Colors.green,
          onPressed: () => makeCallFromChat(context, chat, CallType.voice),
        ),
        
        const SizedBox(width: 8),
        
        // Video call button
        _buildCallButton(
          icon: Icons.videocam,
          label: showLabels ? 'Video' : null,
          color: Colors.blue,
          onPressed: () => makeCallFromChat(context, chat, CallType.video),
        ),
      ],
    );
  }

  /// Build individual call button
  Widget _buildCallButton({
    required IconData icon,
    String? label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, size: 20),
            color: Colors.white,
            onPressed: onPressed,
            padding: EdgeInsets.zero,
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  /// Dispose resources
  void dispose() {
    _callStartedController.close();
    _callEndedController.close();
    _callService.dispose();
  }
}
