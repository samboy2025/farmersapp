import 'dart:io';
import 'package:dio/dio.dart';
import '../models/status.dart';
import '../models/user.dart';
import '../config/app_config.dart';

class ApiResult<T> {
  final bool isSuccess;
  final T? data;
  final String? error;

  ApiResult({
    required this.isSuccess,
    this.data,
    this.error,
  });

  factory ApiResult.success(T data) => ApiResult(
    isSuccess: true,
    data: data,
  );

  factory ApiResult.failure(String error) => ApiResult(
    isSuccess: false,
    error: error,
  );
}

class StatusRepository {
  final Dio _dio;
  final String _baseUrl;

  StatusRepository({Dio? dio})
      : _dio = dio ?? Dio(),
        _baseUrl = AppConfig.apiBaseUrl;

  // Fetch all statuses for the current user
  Future<ApiResult<Map<String, dynamic>>> fetchStatuses() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/statuses',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConfig.authToken}',
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        
        // Parse my statuses
        final myStatuses = (data['my_statuses'] as List)
            .map((json) => Status.fromJson(json))
            .toList();
        
        // Parse other users' statuses
        final otherStatuses = <User, List<Status>>{};
        final statusesByUser = data['statuses_by_user'] as Map<String, dynamic>;
        
        for (final entry in statusesByUser.entries) {
          final user = User.fromJson(entry.value['user']);
          final statuses = (entry.value['statuses'] as List)
              .map((json) => Status.fromJson(json))
              .toList();
          otherStatuses[user] = statuses;
        }

        return ApiResult.success({
          'myStatuses': myStatuses,
          'otherStatuses': otherStatuses,
        });
      } else {
        return ApiResult.failure('Failed to fetch statuses: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResult.failure('Network error: $e');
    }
  }

  // Upload a new status
  Future<ApiResult<Status>> uploadStatus({
    required File mediaFile,
    String? caption,
    StatusPrivacy privacy = StatusPrivacy.public,
    List<String> allowedViewers = const [],
  }) async {
    try {
      // First, upload the media file
      final mediaUploadResult = await _uploadMedia(mediaFile);
      if (!mediaUploadResult.isSuccess) {
        return ApiResult.failure(mediaUploadResult.error!);
      }

      final mediaUrl = mediaUploadResult.data!['url'];
      final thumbnailUrl = mediaUploadResult.data!['thumbnail_url'];
      final duration = mediaUploadResult.data!['duration'];
      final mediaType = mediaUploadResult.data!['type'];

      // Determine status type based on media
      final statusType = mediaType == 'video' ? StatusType.video : StatusType.image;

      // Create status entry
      final response = await _dio.post(
        '$_baseUrl/statuses',
        data: {
          'media_url': mediaUrl,
          'thumbnail_url': thumbnailUrl,
          'type': statusType.name,
          'caption': caption,
          'privacy': privacy.name,
          'allowed_viewers': allowedViewers,
          'duration': duration,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConfig.authToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201) {
        final status = Status.fromJson(response.data);
        return ApiResult.success(status);
      } else {
        return ApiResult.failure('Failed to create status: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResult.failure('Upload error: $e');
    }
  }

  // Upload media file and get URL
  Future<ApiResult<Map<String, dynamic>>> _uploadMedia(File mediaFile) async {
    try {
      final formData = FormData.fromMap({
        'media': await MultipartFile.fromFile(
          mediaFile.path,
          filename: mediaFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '$_baseUrl/media/upload',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConfig.authToken}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return ApiResult.success(response.data);
      } else {
        return ApiResult.failure('Media upload failed: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResult.failure('Media upload error: $e');
    }
  }

  // Mark status as viewed
  Future<ApiResult<bool>> markStatusAsViewed(String statusId) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/statuses/$statusId/view',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConfig.authToken}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return ApiResult.success(true);
      } else {
        return ApiResult.failure('Failed to mark status as viewed: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResult.failure('Network error: $e');
    }
  }

  // Delete a status
  Future<ApiResult<bool>> deleteStatus(String statusId) async {
    try {
      final response = await _dio.delete(
        '$_baseUrl/statuses/$statusId',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConfig.authToken}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return ApiResult.success(true);
      } else {
        return ApiResult.failure('Failed to delete status: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResult.failure('Network error: $e');
    }
  }

  // Add reaction to status
  Future<ApiResult<bool>> addReaction({
    required String statusId,
    required String emoji,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/statuses/$statusId/reactions',
        data: {
          'emoji': emoji,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConfig.authToken}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        return ApiResult.success(true);
      } else {
        return ApiResult.failure('Failed to add reaction: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResult.failure('Network error: $e');
    }
  }

  // Remove reaction from status
  Future<ApiResult<bool>> removeReaction(String statusId) async {
    try {
      final response = await _dio.delete(
        '$_baseUrl/statuses/$statusId/reactions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConfig.authToken}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return ApiResult.success(true);
      } else {
        return ApiResult.failure('Failed to remove reaction: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResult.failure('Network error: $e');
    }
  }

  // Get status analytics
  Future<ApiResult<Map<String, dynamic>>> getStatusAnalytics(String statusId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/statuses/$statusId/analytics',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConfig.authToken}',
          },
        ),
      );

      if (response.statusCode == 200) {
        return ApiResult.success(response.data);
      } else {
        return ApiResult.failure('Failed to get analytics: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResult.failure('Network error: $e');
    }
  }

  // Get user's status archive
  Future<ApiResult<List<Status>>> getStatusArchive() async {
    try {
      final response = await _dio.get(
        '$_baseUrl/statuses/archive',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${AppConfig.authToken}',
          },
        ),
      );

      if (response.statusCode == 200) {
        final statuses = (response.data as List)
            .map((json) => Status.fromJson(json))
            .toList();
        return ApiResult.success(statuses);
      } else {
        return ApiResult.failure('Failed to get archive: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResult.failure('Network error: $e');
    }
  }
}
