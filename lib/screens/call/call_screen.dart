import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/user.dart';
import '../../models/call.dart';
import '../../services/mock_data_service.dart';
import 'call_initiation_screen.dart';
import 'incoming_call_screen.dart';
import 'in_call_screen.dart';
import 'call_ending_screen.dart';

enum CallScreenState {
  initiating,
  incoming,
  connected,
  ending,
}

class CallScreen extends StatefulWidget {
  final Call? call;
  final User? receiver;
  final bool isIncoming;
  final CallType callType;

  const CallScreen({
    super.key,
    this.call,
    this.receiver,
    this.isIncoming = false,
    this.callType = CallType.voice,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  CallScreenState _currentState = CallScreenState.initiating;
  Duration _callDuration = Duration.zero;
  late DateTime _callStartTime;
  Timer? _callTimer;

  @override
  void initState() {
    super.initState();

    if (widget.isIncoming) {
      _currentState = CallScreenState.incoming;
    } else {
      // Simulate connection delay for outgoing calls
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _startCall();
        }
      });
    }
  }

  void _startCall() {
    setState(() {
      _currentState = CallScreenState.connected;
    });
    _callStartTime = DateTime.now();
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDuration = DateTime.now().difference(_callStartTime);
        });
      }
    });
  }

  void _acceptCall() {
    _startCall();
  }

  void _rejectCall() {
    _endCall();
  }

  void _endCall() {
    _callTimer?.cancel();
    setState(() {
      _currentState = CallScreenState.ending;
    });

    // Show ending screen for 2 seconds, then navigate properly
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _navigateAfterCallEnd();
      }
    });
  }

  void _navigateAfterCallEnd() {
    // Simply pop the current call screen
    // This should take us back to the previous screen (likely home or chat)
    Navigator.of(context).pop();
  }

  void _sendMessage() {
    // Navigate to quick message composer
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Quick message feature would open here')),
    );
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.receiver ?? MockDataService.getUserById('2');

    // Ensure we have a valid user
    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'User not found',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    switch (_currentState) {
      case CallScreenState.initiating:
        return CallInitiationScreen(
          receiver: user,
          callType: widget.callType,
        );

      case CallScreenState.incoming:
        return IncomingCallScreen(
          caller: user,
          callType: widget.callType,
          onAccept: _acceptCall,
          onReject: _rejectCall,
          onMessageReply: _sendMessage,
        );

      case CallScreenState.connected:
        return InCallScreen(
          otherUser: user,
          callType: widget.callType,
          onEndCall: _endCall,
          isIncoming: widget.isIncoming,
        );

      case CallScreenState.ending:
        return CallEndingScreen(
          duration: _callDuration,
          onComplete: () => Navigator.of(context).pop(),
        );
    }
  }
}
