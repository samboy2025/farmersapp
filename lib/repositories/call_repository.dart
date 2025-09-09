import 'dart:async';
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/call.dart';

import '../services/mock_data_service.dart';

class CallRepository {
  static final CallRepository _instance = CallRepository._internal();
  factory CallRepository() => _instance;
  CallRepository._internal();

  WebSocketChannel? _webSocketChannel;
  final StreamController<Call> _incomingCallController = StreamController<Call>.broadcast();
  final StreamController<Map<String, dynamic>> _callStateController = StreamController<Map<String, dynamic>>.broadcast();
  
  // WebRTC related
  RTCPeerConnection? _peerConnection;
  MediaStream? _localStream;
  MediaStream? _remoteStream;
  
  // Call state
  Call? _currentCall;
  bool _isInitialized = false;

  // Getters
  Stream<Call> get incomingCallStream => _incomingCallController.stream;
  Stream<Map<String, dynamic>> get callStateStream => _callStateController.stream;
  Call? get currentCall => _currentCall;
  bool get isInitialized => _isInitialized;

  /// Initialize the call repository and establish WebSocket connection
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Initialize WebRTC
      await _initializeWebRTC();
      
      // Connect to WebSocket (in real app, this would be your Laravel backend)
      await _connectWebSocket();
      
      _isInitialized = true;
    } catch (e) {
      print('Failed to initialize CallRepository: $e');
      rethrow;
    }
  }

  /// Initialize WebRTC configuration
  Future<void> _initializeWebRTC() async {
    final configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'},
        {'urls': 'stun:stun1.l.google.com:19302'},
      ],
    };

    final constraints = {
      'mandatory': {
        'OfferToReceiveAudio': true,
        'OfferToReceiveVideo': true,
      },
      'optional': [],
    };

    _peerConnection = await createPeerConnection(configuration, constraints);
    
    // Set up event handlers
    _peerConnection!.onIceCandidate = (candidate) {
      _sendSignalingMessage({
        'type': 'ice-candidate',
        'candidate': candidate.toMap(),
        'callId': _currentCall?.id,
      });
    };

    _peerConnection!.onConnectionState = (state) {
      print('Connection state changed: $state');
      _callStateController.add({
        'type': 'connection-state',
        'state': state.toString(),
        'callId': _currentCall?.id,
      });
    };

    _peerConnection!.onTrack = (event) {
      if (event.track.kind == 'video') {
        _remoteStream = event.streams.first;
        _callStateController.add({
          'type': 'remote-stream',
          'stream': _remoteStream,
          'callId': _currentCall?.id,
        });
      }
    };
  }

  /// Connect to WebSocket for signaling
  Future<void> _connectWebSocket() async {
    // In a real app, this would connect to your Laravel backend
    // For now, we'll simulate the connection
    print('WebSocket connection established (simulated)');
    
    // Simulate incoming call after a delay
    Timer(const Duration(seconds: 5), () {
      _simulateIncomingCall();
    });
  }

  /// Simulate an incoming call for testing
  void _simulateIncomingCall() {
    final mockCaller = MockDataService.getUserById('3')!;
    final currentUser = MockDataService.currentUser;
    
    final incomingCall = Call(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      callerId: mockCaller.id,
      receiverId: currentUser.id,
      type: CallType.voice,
      status: CallStatus.incoming,
      startTime: DateTime.now(),
      isIncoming: true,
    );
    
    _incomingCallController.add(incomingCall);
  }

  /// Initiate a call to another user
  Future<Call> initiateCall(String receiverId, CallType type) async {
    if (!_isInitialized) {
      throw Exception('CallRepository not initialized');
    }

    final currentUser = MockDataService.currentUser;
    final receiver = MockDataService.getUserById(receiverId);
    
    if (receiver == null) {
      throw Exception('Receiver not found');
    }

    // Create call object
    final call = Call(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      callerId: currentUser.id,
      receiverId: receiverId,
      type: type,
      status: CallStatus.dialing,
      startTime: DateTime.now(),
      isIncoming: false,
    );

    _currentCall = call;

    try {
      // Get user media
      await _getUserMedia(type);
      
      // Create offer
      final offer = await _peerConnection!.createOffer({
        'offerToReceiveAudio': true,
        'offerToReceiveVideo': type == CallType.video,
      });

      await _peerConnection!.setLocalDescription(offer);

      // Send offer to receiver via WebSocket
      _sendSignalingMessage({
        'type': 'offer',
        'offer': offer.toMap(),
        'callId': call.id,
        'callerId': currentUser.id,
        'receiverId': receiverId,
        'callType': type.name,
      });

      // Update call status
      _updateCallStatus(call.id, CallStatus.dialing);

      return call;
    } catch (e) {
      _currentCall = null;
      throw Exception('Failed to initiate call: $e');
    }
  }

  /// Answer an incoming call
  Future<void> answerCall(String callId) async {
    if (!_isInitialized || _currentCall == null) {
      throw Exception('No active call to answer');
    }

    try {
      // Get user media
      await _getUserMedia(_currentCall!.type);
      
      // Create answer
      final answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      // Send answer to caller via WebSocket
      _sendSignalingMessage({
        'type': 'answer',
        'answer': answer.toMap(),
        'callId': callId,
      });

      // Update call status
      _updateCallStatus(callId, CallStatus.connecting);
      
      // Simulate connection establishment
      Timer(const Duration(seconds: 2), () {
        _updateCallStatus(callId, CallStatus.connected);
      });

    } catch (e) {
      throw Exception('Failed to answer call: $e');
    }
  }

  /// Reject an incoming call
  Future<void> rejectCall(String callId) async {
    _sendSignalingMessage({
      'type': 'reject',
      'callId': callId,
    });

    _updateCallStatus(callId, CallStatus.rejected);
    _cleanupCall();
  }

  /// End an active call
  Future<void> endCall(String callId) async {
    _sendSignalingMessage({
      'type': 'hangup',
      'callId': callId,
    });

    _updateCallStatus(callId, CallStatus.ended);
    _cleanupCall();
  }

  /// Get user media (audio/video)
  Future<void> _getUserMedia(CallType type) async {
    final constraints = {
      'audio': true,
      'video': type == CallType.video ? {
        'facingMode': 'user',
        'width': {'ideal': 1280},
        'height': {'ideal': 720},
      } : false,
    };

    _localStream = await navigator.mediaDevices.getUserMedia(constraints);
    
    // Add local stream to peer connection
    _localStream!.getTracks().forEach((track) {
      _peerConnection!.addTrack(track, _localStream!);
    });
  }

  /// Send signaling message via WebSocket
  void _sendSignalingMessage(Map<String, dynamic> message) {
    if (_webSocketChannel != null) {
      _webSocketChannel!.sink.add(jsonEncode(message));
    } else {
      print('WebSocket not connected, message: $message');
    }
  }

  /// Update call status
  void _updateCallStatus(String callId, CallStatus status) {
    if (_currentCall != null) {
      _currentCall = _currentCall!.copyWith(status: status);
      
      _callStateController.add({
        'type': 'status-change',
        'callId': callId,
        'status': status,
        'call': _currentCall,
      });
    }
  }





  /// Clean up call resources
  void _cleanupCall() {
    _localStream?.dispose();
    _remoteStream?.dispose();
    _peerConnection?.close();
    
    _localStream = null;
    _remoteStream = null;
    _peerConnection = null;
    _currentCall = null;
  }

  /// Toggle mute state
  Future<void> toggleMute() async {
    if (_localStream != null) {
      final audioTrack = _localStream!.getAudioTracks().first;
      audioTrack.enabled = !audioTrack.enabled;
      
      _callStateController.add({
        'type': 'mute-toggled',
        'isMuted': !audioTrack.enabled,
        'callId': _currentCall?.id,
      });
    }
  }

  /// Toggle video state
  Future<void> toggleVideo() async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      videoTrack.enabled = !videoTrack.enabled;
      
      _callStateController.add({
        'type': 'video-toggled',
        'isVideoEnabled': videoTrack.enabled,
        'callId': _currentCall?.id,
      });
    }
  }

  /// Switch camera
  Future<void> switchCamera() async {
    if (_localStream != null) {
      final videoTrack = _localStream!.getVideoTracks().first;
      await Helper.switchCamera(videoTrack);
    }
  }

  /// Get local stream for UI
  MediaStream? getLocalStream() => _localStream;
  
  /// Get remote stream for UI
  MediaStream? getRemoteStream() => _remoteStream;

  /// Dispose resources
  void dispose() {
    _cleanupCall();
    _webSocketChannel?.sink.close();
    _incomingCallController.close();
    _callStateController.close();
    _isInitialized = false;
  }
}
