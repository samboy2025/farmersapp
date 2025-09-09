import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/status.dart';
import '../../models/user.dart';
import '../../repositories/status_repository.dart';

// Events
abstract class StatusEvent extends Equatable {
  const StatusEvent();

  @override
  List<Object?> get props => [];
}

class StatusFetched extends StatusEvent {
  const StatusFetched();
}

class StatusViewed extends StatusEvent {
  final String statusId;
  
  const StatusViewed({required this.statusId});
  
  @override
  List<Object?> get props => [statusId];
}

class StatusUploaded extends StatusEvent {
  final File mediaFile;
  final String? caption;
  final StatusPrivacy privacy;
  final List<String> allowedViewers;
  
  const StatusUploaded({
    required this.mediaFile,
    this.caption,
    this.privacy = StatusPrivacy.public,
    this.allowedViewers = const [],
  });
  
  @override
  List<Object?> get props => [mediaFile, caption, privacy, allowedViewers];
}

class StatusDeleted extends StatusEvent {
  final Status status;
  
  const StatusDeleted({required this.status});
  
  @override
  List<Object?> get props => [status];
}

class StatusReactionAdded extends StatusEvent {
  final String statusId;
  final String emoji;
  
  const StatusReactionAdded({
    required this.statusId,
    required this.emoji,
  });
  
  @override
  List<Object?> get props => [statusId, emoji];
}

class StatusReactionRemoved extends StatusEvent {
  final String statusId;
  
  const StatusReactionRemoved({required this.statusId});
  
  @override
  List<Object?> get props => [statusId];
}

// States
abstract class StatusState extends Equatable {
  const StatusState();

  @override
  List<Object?> get props => [];
}

class StatusInitial extends StatusState {}

class StatusLoadInProgress extends StatusState {}

class StatusLoadSuccess extends StatusState {
  final Map<User, List<Status>> statusUpdates;
  final List<Status> myStatuses;
  
  const StatusLoadSuccess({
    required this.statusUpdates,
    required this.myStatuses,
  });
  
  @override
  List<Object?> get props => [statusUpdates, myStatuses];
}

class StatusUploadInProgress extends StatusState {
  final double progress;
  
  const StatusUploadInProgress({this.progress = 0.0});
  
  @override
  List<Object?> get props => [progress];
}

class StatusUploadSuccess extends StatusState {
  final Status status;
  
  const StatusUploadSuccess({required this.status});
  
  @override
  List<Object?> get props => [status];
}

class StatusOperationFailure extends StatusState {
  final String error;
  
  const StatusOperationFailure({required this.error});
  
  @override
  List<Object?> get props => [error];
}

// Bloc
class StatusBloc extends Bloc<StatusEvent, StatusState> {
  final StatusRepository _statusRepository;
  
  StatusBloc({required StatusRepository statusRepository})
      : _statusRepository = statusRepository,
        super(StatusInitial()) {
    
    on<StatusFetched>(_onStatusFetched);
    on<StatusViewed>(_onStatusViewed);
    on<StatusUploaded>(_onStatusUploaded);
    on<StatusDeleted>(_onStatusDeleted);
    on<StatusReactionAdded>(_onStatusReactionAdded);
    on<StatusReactionRemoved>(_onStatusReactionRemoved);
  }
  
  Future<void> _onStatusFetched(
    StatusFetched event,
    Emitter<StatusState> emit,
  ) async {
    try {
      emit(StatusLoadInProgress());
      
      final result = await _statusRepository.fetchStatuses();
      
      if (result.isSuccess) {
        final statusData = result.data!;
        final myStatuses = statusData['myStatuses'] as List<Status>;
        final otherStatuses = statusData['otherStatuses'] as Map<User, List<Status>>;
        
        emit(StatusLoadSuccess(
          statusUpdates: otherStatuses,
          myStatuses: myStatuses,
        ));
      } else {
        emit(StatusOperationFailure(error: result.error!));
      }
    } catch (e) {
      emit(StatusOperationFailure(error: e.toString()));
    }
  }
  
  Future<void> _onStatusViewed(
    StatusViewed event,
    Emitter<StatusState> emit,
  ) async {
    try {
      final result = await _statusRepository.markStatusAsViewed(event.statusId);
      
      if (result.isSuccess) {
        // Refresh the status list to update viewed status
        add(const StatusFetched());
      } else {
        emit(StatusOperationFailure(error: result.error!));
      }
    } catch (e) {
      emit(StatusOperationFailure(error: e.toString()));
    }
  }
  
  Future<void> _onStatusUploaded(
    StatusUploaded event,
    Emitter<StatusState> emit,
  ) async {
    try {
      emit(const StatusUploadInProgress());
      
      final result = await _statusRepository.uploadStatus(
        mediaFile: event.mediaFile,
        caption: event.caption,
        privacy: event.privacy,
        allowedViewers: event.allowedViewers,
      );
      
      if (result.isSuccess) {
        emit(StatusUploadSuccess(status: result.data!));
        // Refresh the status list
        add(const StatusFetched());
      } else {
        emit(StatusOperationFailure(error: result.error!));
      }
    } catch (e) {
      emit(StatusOperationFailure(error: e.toString()));
    }
  }
  
  Future<void> _onStatusDeleted(
    StatusDeleted event,
    Emitter<StatusState> emit,
  ) async {
    try {
      final result = await _statusRepository.deleteStatus(event.status.id);
      
      if (result.isSuccess) {
        // Refresh the status list
        add(const StatusFetched());
      } else {
        emit(StatusOperationFailure(error: result.error!));
      }
    } catch (e) {
      emit(StatusOperationFailure(error: e.toString()));
    }
  }
  
  Future<void> _onStatusReactionAdded(
    StatusReactionAdded event,
    Emitter<StatusState> emit,
  ) async {
    try {
      final result = await _statusRepository.addReaction(
        statusId: event.statusId,
        emoji: event.emoji,
      );
      
      if (result.isSuccess) {
        // Refresh the status list
        add(const StatusFetched());
      } else {
        emit(StatusOperationFailure(error: result.error!));
      }
    } catch (e) {
      emit(StatusOperationFailure(error: e.toString()));
    }
  }
  
  Future<void> _onStatusReactionRemoved(
    StatusReactionRemoved event,
    Emitter<StatusState> emit,
  ) async {
    try {
      final result = await _statusRepository.removeReaction(event.statusId);
      
      if (result.isSuccess) {
        // Refresh the status list
        add(const StatusFetched());
      } else {
        emit(StatusOperationFailure(error: result.error!));
      }
    } catch (e) {
      emit(StatusOperationFailure(error: e.toString()));
    }
  }
}
