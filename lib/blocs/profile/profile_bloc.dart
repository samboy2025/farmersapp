import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileFetched extends ProfileEvent {}

class ProfileUpdateRequested extends ProfileEvent {
  final String? name;
  final String? about;
  final String? profilePicturePath;

  const ProfileUpdateRequested({
    this.name,
    this.about,
    this.profilePicturePath,
  });

  @override
  List<Object?> get props => [name, about, profilePicturePath];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoadSuccess extends ProfileState {
  final User user;

  const ProfileLoadSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileUpdating extends ProfileState {
  final User user;

  const ProfileUpdating(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileUpdateSuccess extends ProfileState {
  final User user;

  const ProfileUpdateSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileUpdateFailure extends ProfileState {
  final String message;

  const ProfileUpdateFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<ProfileFetched>(_onProfileFetched);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  Future<void> _onProfileFetched(
    ProfileFetched event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      // Use mock data service
      final user = MockDataService.currentUser;
      emit(ProfileLoadSuccess(user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileLoadSuccess) {
      final currentUser = (state as ProfileLoadSuccess).user;
      emit(ProfileUpdating(currentUser));
      
      try {
        // In a real app, this would update via repository
        // For now, just updating the local state
        User updatedUser = currentUser;
        
        if (event.name != null) {
          updatedUser = updatedUser.copyWith(name: event.name);
        }
        
        if (event.about != null) {
          updatedUser = updatedUser.copyWith(about: event.about);
        }
        
        if (event.profilePicturePath != null) {
          // In a real app, this would upload the image first
          updatedUser = updatedUser.copyWith(
            profilePicture: event.profilePicturePath,
          );
        }
        
        emit(ProfileUpdateSuccess(updatedUser));
      } catch (e) {
        emit(ProfileUpdateFailure(e.toString()));
      }
    }
  }
}
