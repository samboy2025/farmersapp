import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/status.dart';

// Events
abstract class StatusViewerEvent extends Equatable {
  const StatusViewerEvent();

  @override
  List<Object?> get props => [];
}

class StatusViewerStarted extends StatusViewerEvent {
  final List<Status> statuses;
  final int startIndex;
  
  const StatusViewerStarted({
    required this.statuses,
    this.startIndex = 0,
  });
  
  @override
  List<Object?> get props => [statuses, startIndex];
}

class StatusViewerPlay extends StatusViewerEvent {}

class StatusViewerPause extends StatusViewerEvent {}

class StatusViewerNext extends StatusViewerEvent {}

class StatusViewerPrevious extends StatusViewerEvent {}

class StatusViewerSeek extends StatusViewerEvent {
  final Duration position;
  
  const StatusViewerSeek({required this.position});
  
  @override
  List<Object?> get props => [position];
}

class StatusViewerExited extends StatusViewerEvent {}

// States
abstract class StatusViewerState extends Equatable {
  const StatusViewerState();

  @override
  List<Object?> get props => [];
}

class StatusViewerInitial extends StatusViewerState {}

class StatusViewerReady extends StatusViewerState {
  final Status currentStatus;
  final int currentIndex;
  final int totalCount;
  final List<Status> allStatuses;
  
  const StatusViewerReady({
    required this.currentStatus,
    required this.currentIndex,
    required this.totalCount,
    required this.allStatuses,
  });
  
  @override
  List<Object?> get props => [currentStatus, currentIndex, totalCount, allStatuses];
}

class StatusViewerPlaying extends StatusViewerState {
  final Status currentStatus;
  final int currentIndex;
  final int totalCount;
  final Duration position;
  final Duration totalDuration;
  final List<Status> allStatuses;
  
  const StatusViewerPlaying({
    required this.currentStatus,
    required this.currentIndex,
    required this.totalCount,
    required this.position,
    required this.totalDuration,
    required this.allStatuses,
  });
  
  @override
  List<Object?> get props => [
    currentStatus, 
    currentIndex, 
    totalCount, 
    position, 
    totalDuration,
    allStatuses,
  ];
}

class StatusViewerPaused extends StatusViewerState {
  final Status currentStatus;
  final int currentIndex;
  final int totalCount;
  final Duration position;
  final Duration totalDuration;
  final List<Status> allStatuses;
  
  const StatusViewerPaused({
    required this.currentStatus,
    required this.currentIndex,
    required this.totalCount,
    required this.position,
    required this.totalDuration,
    required this.allStatuses,
  });
  
  @override
  List<Object?> get props => [
    currentStatus, 
    currentIndex, 
    totalCount, 
    position, 
    totalDuration,
    allStatuses,
  ];
}

class StatusViewerFinished extends StatusViewerState {
  final List<Status> allStatuses;
  
  const StatusViewerFinished({required this.allStatuses});
  
  @override
  List<Object?> get props => [allStatuses];
}

// Bloc
class StatusViewerBloc extends Bloc<StatusViewerEvent, StatusViewerState> {
  static const Duration _statusDuration = Duration(seconds: 5);
  
  StatusViewerBloc() : super(StatusViewerInitial()) {
    on<StatusViewerStarted>(_onStatusViewerStarted);
    on<StatusViewerPlay>(_onStatusViewerPlay);
    on<StatusViewerPause>(_onStatusViewerPause);
    on<StatusViewerNext>(_onStatusViewerNext);
    on<StatusViewerPrevious>(_onStatusViewerPrevious);
    on<StatusViewerSeek>(_onStatusViewerSeek);
    on<StatusViewerExited>(_onStatusViewerExited);
  }
  
  void _onStatusViewerStarted(
    StatusViewerStarted event,
    Emitter<StatusViewerState> emit,
  ) {
    if (event.statuses.isEmpty) {
      emit(const StatusViewerFinished(allStatuses: []));
      return;
    }
    
    final startIndex = event.startIndex.clamp(0, event.statuses.length - 1);
    final currentStatus = event.statuses[startIndex];
    
    emit(StatusViewerReady(
      currentStatus: currentStatus,
      currentIndex: startIndex,
      totalCount: event.statuses.length,
      allStatuses: event.statuses,
    ));
    
    // Auto-start playback for images, prepare for videos
    if (currentStatus.isImage) {
      _startImageTimer(emit, event.statuses, startIndex);
    } else if (currentStatus.isVideo) {
      // Video will be handled by the UI when player is ready
    }
  }
  
  void _onStatusViewerPlay(
    StatusViewerPlay event,
    Emitter<StatusViewerState> emit,
  ) {
    final currentState = state;
    if (currentState is StatusViewerReady) {
      _startImageTimer(emit, currentState.allStatuses, currentState.currentIndex);
    } else if (currentState is StatusViewerPaused) {
      // Resume video playback - this will be handled by the UI
      emit(StatusViewerPlaying(
        currentStatus: currentState.currentStatus,
        currentIndex: currentState.currentIndex,
        totalCount: currentState.totalCount,
        position: currentState.position,
        totalDuration: currentState.totalDuration,
        allStatuses: currentState.allStatuses,
      ));
    }
  }
  
  void _onStatusViewerPause(
    StatusViewerPause event,
    Emitter<StatusViewerState> emit,
  ) {
    if (state is StatusViewerPlaying) {
      final currentState = state as StatusViewerPlaying;
      emit(StatusViewerPaused(
        currentStatus: currentState.currentStatus,
        currentIndex: currentState.currentIndex,
        totalCount: currentState.totalCount,
        position: currentState.position,
        totalDuration: currentState.totalDuration,
        allStatuses: currentState.allStatuses,
      ));
    }
  }
  
  void _onStatusViewerNext(
    StatusViewerNext event,
    Emitter<StatusViewerState> emit,
  ) {
    final currentState = state;
    if (currentState is StatusViewerReady) {
      final nextIndex = currentState.currentIndex + 1;
      if (nextIndex < currentState.totalCount) {
        final nextStatus = currentState.allStatuses[nextIndex];
        emit(StatusViewerReady(
          currentStatus: nextStatus,
          currentIndex: nextIndex,
          totalCount: currentState.totalCount,
          allStatuses: currentState.allStatuses,
        ));
        
        if (nextStatus.isImage) {
          _startImageTimer(emit, currentState.allStatuses, nextIndex);
        }
      } else {
        // Reached the end
        emit(StatusViewerFinished(allStatuses: currentState.allStatuses));
      }
    } else if (currentState is StatusViewerPlaying) {
      final nextIndex = currentState.currentIndex + 1;
      if (nextIndex < currentState.totalCount) {
        final nextStatus = currentState.allStatuses[nextIndex];
        emit(StatusViewerReady(
          currentStatus: nextStatus,
          currentIndex: nextIndex,
          totalCount: currentState.totalCount,
          allStatuses: currentState.allStatuses,
        ));
        
        if (nextStatus.isImage) {
          _startImageTimer(emit, currentState.allStatuses, nextIndex);
        }
      } else {
        // Reached the end
        emit(StatusViewerFinished(allStatuses: currentState.allStatuses));
      }
    } else if (currentState is StatusViewerPaused) {
      final nextIndex = currentState.currentIndex + 1;
      if (nextIndex < currentState.totalCount) {
        final nextStatus = currentState.allStatuses[nextIndex];
        emit(StatusViewerReady(
          currentStatus: nextStatus,
          currentIndex: nextIndex,
          totalCount: currentState.totalCount,
          allStatuses: currentState.allStatuses,
        ));
        
        if (nextStatus.isImage) {
          _startImageTimer(emit, currentState.allStatuses, nextIndex);
        }
      } else {
        // Reached the end
        emit(StatusViewerFinished(allStatuses: currentState.allStatuses));
      }
    }
  }
  
  void _onStatusViewerPrevious(
    StatusViewerPrevious event,
    Emitter<StatusViewerState> emit,
  ) {
    final currentState = state;
    if (currentState is StatusViewerReady) {
      final prevIndex = currentState.currentIndex - 1;
      if (prevIndex >= 0) {
        final prevStatus = currentState.allStatuses[prevIndex];
        emit(StatusViewerReady(
          currentStatus: prevStatus,
          currentIndex: prevIndex,
          totalCount: currentState.totalCount,
          allStatuses: currentState.allStatuses,
        ));
        
        if (prevStatus.isImage) {
          _startImageTimer(emit, currentState.allStatuses, prevIndex);
        }
      }
    } else if (currentState is StatusViewerPlaying) {
      final prevIndex = currentState.currentIndex - 1;
      if (prevIndex >= 0) {
        final prevStatus = currentState.allStatuses[prevIndex];
        emit(StatusViewerReady(
          currentStatus: prevStatus,
          currentIndex: prevIndex,
          totalCount: currentState.totalCount,
          allStatuses: currentState.allStatuses,
        ));
        
        if (prevStatus.isImage) {
          _startImageTimer(emit, currentState.allStatuses, prevIndex);
        }
      }
    } else if (currentState is StatusViewerPaused) {
      final prevIndex = currentState.currentIndex - 1;
      if (prevIndex >= 0) {
        final prevStatus = currentState.allStatuses[prevIndex];
        emit(StatusViewerReady(
          currentStatus: prevStatus,
          currentIndex: prevIndex,
          totalCount: currentState.totalCount,
          allStatuses: currentState.allStatuses,
        ));
        
        if (prevStatus.isImage) {
          _startImageTimer(emit, currentState.allStatuses, prevIndex);
        }
      }
    }
  }
  
  void _onStatusViewerSeek(
    StatusViewerSeek event,
    Emitter<StatusViewerState> emit,
  ) {
    final currentState = state;
    if (currentState is StatusViewerPlaying) {
      // Update position - this will be handled by the UI for video seeking
      emit(StatusViewerPlaying(
        currentStatus: currentState.currentStatus,
        currentIndex: currentState.currentIndex,
        totalCount: currentState.totalCount,
        position: event.position,
        totalDuration: currentState.totalDuration,
        allStatuses: currentState.allStatuses,
      ));
    } else if (currentState is StatusViewerPaused) {
      emit(StatusViewerPaused(
        currentStatus: currentState.currentStatus,
        currentIndex: currentState.currentIndex,
        totalCount: currentState.totalCount,
        position: event.position,
        totalDuration: currentState.totalDuration,
        allStatuses: currentState.allStatuses,
      ));
    }
  }
  
  void _onStatusViewerExited(
    StatusViewerExited event,
    Emitter<StatusViewerState> emit,
  ) {
    emit(StatusViewerInitial());
  }
  
  void _startImageTimer(
    Emitter<StatusViewerState> emit,
    List<Status> statuses,
    int currentIndex,
  ) {
    Future.delayed(_statusDuration, () {
      if (state is StatusViewerReady && 
          (state as StatusViewerReady).currentIndex == currentIndex) {
        add(StatusViewerNext());
      }
    });
  }
}
