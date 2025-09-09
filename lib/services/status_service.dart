import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/status.dart';
import '../models/user.dart';
import '../config/app_config.dart';

class StatusService {
  static final StatusService _instance = StatusService._internal();
  factory StatusService() => _instance;
  StatusService._internal();

  final ImagePicker _imagePicker = ImagePicker();
  final StreamController<List<Status>> _statusUpdatesController = 
      StreamController<List<Status>>.broadcast();
  
  Timer? _statusCleanupTimer;
  final Map<String, DateTime> _viewedStatuses = {};

  // Stream for real-time status updates
  Stream<List<Status>> get statusUpdatesStream => _statusUpdatesController.stream;

  // Initialize the service
  Future<void> initialize() async {
    _startStatusCleanupTimer();
    _requestPermissions();
  }

  // Request necessary permissions
  Future<void> _requestPermissions() async {
    await Permission.camera.request();
    await Permission.photos.request();
    await Permission.storage.request();
  }

  // Start timer to clean up expired statuses
  void _startStatusCleanupTimer() {
    _statusCleanupTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _cleanupExpiredStatuses(),
    );
  }

  // Clean up expired statuses
  void _cleanupExpiredStatuses() {
    // This would typically be handled by the backend
    // For now, we'll just emit an update to refresh the UI
    _statusUpdatesController.add([]);
  }

  // Pick image from gallery
  Future<File?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Take photo with camera
  Future<File?> takePhotoWithCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );
      
      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      print('Error taking photo: $e');
      return null;
    }
  }

  // Record video
  Future<File?> recordVideo() async {
    try {
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: 30),
      );
      
      if (video != null) {
        return File(video.path);
      }
      return null;
    } catch (e) {
      print('Error recording video: $e');
      return null;
    }
  }

  // Create text status
  Future<Status?> createTextStatus({
    required String text,
    required User author,
    StatusPrivacy privacy = StatusPrivacy.public,
    List<String> allowedViewers = const [],
  }) async {
    try {
      final status = Status(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        author: author,
        type: StatusType.text,
        caption: text,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        privacy: privacy,
        allowedViewers: allowedViewers,
      );

      // In a real app, this would be sent to the backend
      // For now, we'll just return the status
      return status;
    } catch (e) {
      print('Error creating text status: $e');
      return null;
    }
  }

  // Create media status
  Future<Status?> createMediaStatus({
    required File mediaFile,
    required User author,
    String? caption,
    StatusPrivacy privacy = StatusPrivacy.public,
    List<String> allowedViewers = const [],
  }) async {
    try {
      // Determine media type
      final StatusType mediaType = _getMediaType(mediaFile);
      
      // Generate thumbnail for video
      String? thumbnailUrl;
      Duration? duration;
      
      if (mediaType == StatusType.video) {
        // In a real app, you'd generate a thumbnail here
        thumbnailUrl = mediaFile.path;
        duration = const Duration(seconds: 30); // Mock duration
      }

      final status = Status(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        author: author,
        mediaUrl: mediaFile.path,
        type: mediaType,
        caption: caption,
        createdAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(hours: 24)),
        privacy: privacy,
        allowedViewers: allowedViewers,
        thumbnailUrl: thumbnailUrl,
        duration: duration,
      );

      return status;
    } catch (e) {
      print('Error creating media status: $e');
      return null;
    }
  }

  // Get media type from file
  StatusType _getMediaType(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    if (['mp4', 'avi', 'mov', 'mkv'].contains(extension)) {
      return StatusType.video;
    }
    return StatusType.image;
  }

  // Mark status as viewed
  void markStatusAsViewed(String statusId) {
    _viewedStatuses[statusId] = DateTime.now();
    // In a real app, this would be sent to the backend
  }

  // Check if status is viewed
  bool isStatusViewed(String statusId) {
    return _viewedStatuses.containsKey(statusId);
  }

  // Get status analytics
  Map<String, dynamic> getStatusAnalytics(Status status) {
    final now = DateTime.now();
    final timeSinceCreation = now.difference(status.createdAt);
    
    return {
      'views': status.viewCount,
      'reactions': status.reactions.length,
      'timeSinceCreation': timeSinceCreation.inMinutes,
      'isActive': status.isActive,
      'privacy': status.privacy.name,
    };
  }

  // Add reaction to status
  void addReaction(Status status, User user, String emoji) {
    // In a real app, this would update the backend
    // For now, we'll just print the reaction
    print('${user.name} reacted with $emoji to status ${status.id}');
  }

  // Delete status
  Future<bool> deleteStatus(Status status) async {
    try {
      // In a real app, this would delete from the backend
      // For now, we'll just return success
      return true;
    } catch (e) {
      print('Error deleting status: $e');
      return false;
    }
  }

  // Get status archive (expired statuses)
  List<Status> getStatusArchive(List<Status> allStatuses) {
    return allStatuses.where((status) => status.isExpired).toList();
  }

  // Get active statuses
  List<Status> getActiveStatuses(List<Status> allStatuses) {
    return allStatuses.where((status) => status.isActive).toList();
  }

  // Filter statuses by privacy
  List<Status> filterStatusesByPrivacy(
    List<Status> statuses,
    User currentUser,
    StatusPrivacy privacy,
  ) {
    return statuses.where((status) {
      if (privacy == StatusPrivacy.public) return true;
      if (privacy == StatusPrivacy.contactsOnly) return true;
      if (privacy == StatusPrivacy.custom) {
        return status.allowedViewers.contains(currentUser.id);
      }
      return false;
    }).toList();
  }

  // Dispose resources
  void dispose() {
    _statusCleanupTimer?.cancel();
    _statusUpdatesController.close();
  }
}
