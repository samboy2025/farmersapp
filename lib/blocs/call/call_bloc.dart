import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import '../../models/call.dart';
import '../../models/user.dart';
import '../../repositories/call_repository.dart';
import '../../services/mock_data_service.dart';

// Events
abstract class CallEvent extends Equatable {
  const CallEvent();

  @override
  List<Object?> get props => [];
}

class CallInitiated extends CallEvent {
  final String receiverId;
  final CallType type;

  const CallInitiated({
    required this.receiverId,
    required this.type,
  });

  @override
  List<Object?> get props => [receiverId, type];
}

class CallAnswered extends CallEvent {
  final String callId;

  const CallAnswered(this.callId);

  @override
  List<Object?> get props => [callId];
}

class CallHungUp extends CallEvent {
  final String callId;

  const CallHungUp(this.callId);

  @override
  List<Object?> get props => [callId];
}

class CallRejected extends CallEvent {
  final String callId;

  const CallRejected(this.callId);

  @override
  List<Object?> get props => [callId];
}

class IncomingCallReceived extends CallEvent {
  final Call call;

  const IncomingCallReceived(this.call);

  @override
  List<Object?> get props => [call];
}

class CallStateChanged extends CallEvent {
  final String callId;
  final CallStatus status;

  const CallStateChanged({
    required this.callId,
    required this.status,
  });

  @override
  List<Object?> get props => [callId, status];
}

class CallToggleMute extends CallEvent {
  const CallToggleMute();
}

class CallToggleVideo extends CallEvent {
  const CallToggleVideo();
}

class CallSwitchCamera extends CallEvent {
  const CallSwitchCamera();
}

class CallToggleSpeaker extends CallEvent {
  const CallToggleSpeaker();
}

class CallRepositoryInitialized extends CallEvent {
  const CallRepositoryInitialized();
}

// States
abstract class CallState extends Equatable {
  const CallState();

  @override
  List<Object?> get props => [];
}

class CallInitial extends CallState {}

class CallRepositoryLoading extends CallState {}

class CallRepositoryReady extends CallState {}

class CallDialing extends CallState {
  final Call call;
  final User receiver;

  const CallDialing({
    required this.call,
    required this.receiver,
  });

  @override
  List<Object?> get props => [call, receiver];
}

class CallIncoming extends CallState {
  final Call call;
  final User caller;

  const CallIncoming({
    required this.call,
    required this.caller,
  });

  @override
  List<Object?> get props => [call, caller];
}

class CallConnecting extends CallState {
  final Call call;
  final User otherUser;

  const CallConnecting({
    required this.call,
    required this.otherUser,
  });

  @override
  List<Object?> get props => [call, otherUser];
}

class CallConnected extends CallState {
  final Call call;
  final User otherUser;
  final DateTime startTime;
  final bool isMuted;
  final bool isVideoEnabled;
  final bool isSpeakerOn;

  const CallConnected({
    required this.call,
    required this.otherUser,
    required this.startTime,
    this.isMuted = false,
    this.isVideoEnabled = true,
    this.isSpeakerOn = false,
  });

  CallConnected copyWith({
    Call? call,
    User? otherUser,
    DateTime? startTime,
    bool? isMuted,
    bool? isVideoEnabled,
    bool? isSpeakerOn,
  }) {
    return CallConnected(
      call: call ?? this.call,
      otherUser: otherUser ?? this.otherUser,
      startTime: startTime ?? this.startTime,
      isMuted: isMuted ?? this.isMuted,
      isVideoEnabled: isVideoEnabled ?? this.isVideoEnabled,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
    );
  }

  @override
  List<Object?> get props => [call, otherUser, startTime, isMuted, isVideoEnabled, isSpeakerOn];
}

class CallEnded extends CallState {
  final Call call;
  final Duration duration;
  final CallEndReason reason;

  const CallEnded({
    required this.call,
    required this.duration,
    required this.reason,
  });

  @override
  List<Object?> get props => [call, duration, reason];
}

class CallFailed extends CallState {
  final String message;
  final Call? call;

  const CallFailed(this.message, {this.call});

  @override
  List<Object?> get props => [message, call];
}

enum CallEndReason {
  hungUp,
  rejected,
  networkError,
  userBusy,
  noAnswer,
  callEnded,
}

// Bloc
class CallBloc extends Bloc<CallEvent, CallState> {
  final CallRepository _callRepository;
  StreamSubscription<Call>? _incomingCallSubscription;
  StreamSubscription<Map<String, dynamic>>? _callStateSubscription;

  CallBloc({CallRepository? callRepository}) 
      : _callRepository = callRepository ?? CallRepository(),
        super(CallInitial()) {
    on<CallRepositoryInitialized>(_onCallRepositoryInitialized);
    on<CallInitiated>(_onCallInitiated);
    on<CallAnswered>(_onCallAnswered);
    on<CallHungUp>(_onCallHungUp);
    on<CallRejected>(_onCallRejected);
    on<IncomingCallReceived>(_onIncomingCallReceived);
    on<CallStateChanged>(_onCallStateChanged);
    on<CallToggleMute>(_onCallToggleMute);
    on<CallToggleVideo>(_onCallToggleVideo);
    on<CallSwitchCamera>(_onCallSwitchCamera);
    on<CallToggleSpeaker>(_onCallToggleSpeaker);

    // Initialize the repository
    _initializeRepository();
  }

  Future<void> _initializeRepository() async {
    try {
      await _callRepository.initialize();
      
      // Listen to incoming calls
      _incomingCallSubscription = _callRepository.incomingCallStream.listen((call) {
        add(IncomingCallReceived(call));
      });

      // Listen to call state changes
      _callStateSubscription = _callRepository.callStateStream.listen((data) {
        final type = data['type'] as String;
        final callId = data['callId'] as String;
        
        switch (type) {
          case 'status-change':
            final status = data['status'] as CallStatus;
            add(CallStateChanged(callId: callId, status: status));
            break;
          case 'mute-toggled':
            add(CallToggleMute());
            break;
          case 'video-toggled':
            add(CallToggleVideo());
            break;
        }
      });

      // Emit ready state through proper event
      add(CallRepositoryInitialized());
    } catch (e) {
      // Emit failed state through proper event
      add(CallRepositoryInitialized());
    }
  }

  void _onCallRepositoryInitialized(
    CallRepositoryInitialized event,
    Emitter<CallState> emit,
  ) {
    emit(CallRepositoryReady());
  }

  Future<void> _onCallInitiated(
    CallInitiated event,
    Emitter<CallState> emit,
  ) async {
    try {
      final call = await _callRepository.initiateCall(event.receiverId, event.type);
      final receiver = MockDataService.getUserById(event.receiverId);
      
      if (receiver != null) {
        emit(CallDialing(call: call, receiver: receiver));
      } else {
        emit(CallFailed('Receiver not found'));
      }
    } catch (e) {
      emit(CallFailed('Failed to initiate call: $e'));
    }
  }

  Future<void> _onCallAnswered(
    CallAnswered event,
    Emitter<CallState> emit,
  ) async {
    try {
      await _callRepository.answerCall(event.callId);
      
      if (state is CallIncoming) {
        final currentState = state as CallIncoming;
        emit(CallConnecting(
          call: currentState.call,
          otherUser: currentState.caller,
        ));
      }
    } catch (e) {
      emit(CallFailed('Failed to answer call: $e'));
    }
  }

  Future<void> _onCallHungUp(
    CallHungUp event,
    Emitter<CallState> emit,
  ) async {
    try {
      await _callRepository.endCall(event.callId);
      
      if (state is CallConnected) {
        final currentState = state as CallConnected;
        final duration = DateTime.now().difference(currentState.startTime);
        
        emit(CallEnded(
          call: currentState.call,
          duration: duration,
          reason: CallEndReason.hungUp,
        ));
      } else if (state is CallDialing) {
        emit(CallEnded(
          call: (state as CallDialing).call,
          duration: Duration.zero,
          reason: CallEndReason.hungUp,
        ));
      } else {
        emit(CallInitial());
      }
    } catch (e) {
      emit(CallFailed('Failed to end call: $e'));
    }
  }

  Future<void> _onCallRejected(
    CallRejected event,
    Emitter<CallState> emit,
  ) async {
    try {
      await _callRepository.rejectCall(event.callId);
      
      if (state is CallIncoming) {
        final currentState = state as CallIncoming;
        emit(CallEnded(
          call: currentState.call,
          duration: Duration.zero,
          reason: CallEndReason.rejected,
        ));
      }
    } catch (e) {
      emit(CallFailed('Failed to reject call: $e'));
    }
  }

  void _onIncomingCallReceived(
    IncomingCallReceived event,
    Emitter<CallState> emit,
  ) {
    final caller = MockDataService.getUserById(event.call.callerId);
    if (caller != null) {
      emit(CallIncoming(call: event.call, caller: caller));
    }
  }

  void _onCallStateChanged(
    CallStateChanged event,
    Emitter<CallState> emit,
  ) {
    switch (event.status) {
      case CallStatus.connecting:
        if (state is CallDialing) {
          final currentState = state as CallDialing;
          emit(CallConnecting(
            call: currentState.call,
            otherUser: currentState.receiver,
          ));
        } else if (state is CallIncoming) {
          final currentState = state as CallIncoming;
          emit(CallConnecting(
            call: currentState.call,
            otherUser: currentState.caller,
          ));
        }
        break;
      case CallStatus.connected:
        if (state is CallConnecting) {
          final currentState = state as CallConnecting;
          emit(CallConnected(
            call: currentState.call,
            otherUser: currentState.otherUser,
            startTime: DateTime.now(),
          ));
        }
        break;
      case CallStatus.ended:
        if (state is CallConnected) {
          final currentState = state as CallConnected;
          final duration = DateTime.now().difference(currentState.startTime);
          emit(CallEnded(
            call: currentState.call,
            duration: duration,
            reason: CallEndReason.callEnded,
          ));
        }
        break;
      case CallStatus.failed:
        if (state is CallDialing || state is CallConnecting) {
          final call = state is CallDialing 
              ? (state as CallDialing).call 
              : (state as CallConnecting).call;
          emit(CallFailed('Call failed', call: call));
        }
        break;
      default:
        // Handle other states as needed
        break;
    }
  }

  Future<void> _onCallToggleMute(
    CallToggleMute event,
    Emitter<CallState> emit,
  ) async {
    try {
      await _callRepository.toggleMute();
      
      if (state is CallConnected) {
        final currentState = state as CallConnected;
        emit(currentState.copyWith(isMuted: !currentState.isMuted));
      }
    } catch (e) {
      // Handle error silently for UI state changes
    }
  }

  Future<void> _onCallToggleVideo(
    CallToggleVideo event,
    Emitter<CallState> emit,
  ) async {
    try {
      await _callRepository.toggleVideo();
      
      if (state is CallConnected) {
        final currentState = state as CallConnected;
        emit(currentState.copyWith(isVideoEnabled: !currentState.isVideoEnabled));
      }
    } catch (e) {
      // Handle error silently for UI state changes
    }
  }

  Future<void> _onCallSwitchCamera(
    CallSwitchCamera event,
    Emitter<CallState> emit,
  ) async {
    try {
      await _callRepository.switchCamera();
    } catch (e) {
      // Handle error silently for UI state changes
    }
  }

  void _onCallToggleSpeaker(
    CallToggleSpeaker event,
    Emitter<CallState> emit,
  ) {
    if (state is CallConnected) {
      final currentState = state as CallConnected;
      emit(currentState.copyWith(isSpeakerOn: !currentState.isSpeakerOn));
    }
  }

  /// Get the current call from repository
  Call? get currentCall => _callRepository.currentCall;

  /// Check if call repository is ready
  bool get isRepositoryReady => _callRepository.isInitialized;

  @override
  Future<void> close() {
    _incomingCallSubscription?.cancel();
    _callStateSubscription?.cancel();
    return super.close();
  }
}
