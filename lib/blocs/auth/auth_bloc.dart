import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String phoneNumber;

  const AuthLoginRequested(this.phoneNumber);

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthOtpVerified extends AuthEvent {
  final String phoneNumber;
  final String otp;

  const AuthOtpVerified({
    required this.phoneNumber,
    required this.otp,
  });

  @override
  List<Object?> get props => [phoneNumber, otp];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthRefreshRequested extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  final String token;

  const AuthSuccess({
    required this.user,
    required this.token,
  });

  @override
  List<Object?> get props => [user, token];
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class OtpSent extends AuthState {
  final String phoneNumber;
  final String message;

  const OtpSent({
    required this.phoneNumber,
    required this.message,
  });

  @override
  List<Object?> get props => [phoneNumber, message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthOtpVerified>(_onAuthOtpVerified);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthRefreshRequested>(_onAuthRefreshRequested);
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock OTP sent response
    emit(OtpSent(
      phoneNumber: event.phoneNumber,
      message: 'OTP sent successfully to ${event.phoneNumber}',
    ));
  }

  Future<void> _onAuthOtpVerified(
    AuthOtpVerified event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock OTP verification - accept any OTP for demo
    if (event.otp.length >= 4) {
      final user = MockDataService.currentUser;
      emit(AuthSuccess(user: user, token: 'demo_token_${DateTime.now().millisecondsSinceEpoch}'));
    } else {
      emit(AuthFailure('Invalid OTP. Please try again.'));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    emit(AuthInitial());
  }

  Future<void> _onAuthRefreshRequested(
    AuthRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock token refresh
    final user = MockDataService.currentUser;
    emit(AuthSuccess(user: user, token: 'refreshed_token_${DateTime.now().millisecondsSinceEpoch}'));
  }
}
