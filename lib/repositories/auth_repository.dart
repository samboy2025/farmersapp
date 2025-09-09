import 'package:dio/dio.dart';
import '../models/user.dart';

class AuthRepository {
  final Dio _dio;
  final String _baseUrl;

  AuthRepository({required Dio dio, required String baseUrl})
      : _dio = dio,
        _baseUrl = baseUrl;

  Future<String> sendOtp(String phoneNumber) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/send-otp',
        data: {'phone_number': phoneNumber},
      );
      return response.data['message'] as String;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<User> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/auth/verify-otp',
        data: {
          'phone_number': phoneNumber,
          'otp': otp,
        },
      );
      
      final userData = response.data['user'] as Map<String, dynamic>;
      final token = response.data['token'] as String;
      
      // Store token for future requests
      _dio.options.headers['Authorization'] = 'Bearer $token';
      
      return User.fromJson(userData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('$_baseUrl/auth/logout');
      // Clear token
      _dio.options.headers.remove('Authorization');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<User> refreshToken() async {
    try {
      final response = await _dio.post('$_baseUrl/auth/refresh');
      final userData = response.data['user'] as Map<String, dynamic>;
      final token = response.data['token'] as String;
      
      // Update token
      _dio.options.headers['Authorization'] = 'Bearer $token';
      
      return User.fromJson(userData);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? 'Authentication failed';
        return Exception('$message (Status: $statusCode)');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error. Please check your connection.');
    }
  }
}
