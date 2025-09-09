import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

enum MediaSource {
  camera,
  gallery,
}

class MediaPickerService {
  static final MediaPickerService _instance = MediaPickerService._internal();
  factory MediaPickerService() => _instance;
  MediaPickerService._internal();

  final ImagePicker _imagePicker = ImagePicker();

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();
    return status.isGranted;
  }

  Future<File?> pickImage(MediaSource source) async {
    try {
      XFile? pickedFile;

      switch (source) {
        case MediaSource.camera:
          final hasPermission = await _requestPermission(Permission.camera);
          if (!hasPermission) {
            throw Exception('Camera permission denied');
          }
          pickedFile = await _imagePicker.pickImage(
            source: ImageSource.camera,
            imageQuality: 80,
            maxWidth: 1920,
            maxHeight: 1080,
          );
          break;

        case MediaSource.gallery:
          final hasPermission = await _requestPermission(Permission.photos);
          if (!hasPermission) {
            throw Exception('Gallery permission denied');
          }
          pickedFile = await _imagePicker.pickImage(
            source: ImageSource.gallery,
            imageQuality: 80,
            maxWidth: 1920,
            maxHeight: 1080,
          );
          break;
      }

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick image: $e');
    }
  }

  Future<File?> pickVideo(MediaSource source) async {
    try {
      XFile? pickedFile;

      switch (source) {
        case MediaSource.camera:
          final hasPermission = await _requestPermission(Permission.camera);
          if (!hasPermission) {
            throw Exception('Camera permission denied');
          }
          pickedFile = await _imagePicker.pickVideo(
            source: ImageSource.camera,
            maxDuration: const Duration(minutes: 5),
          );
          break;

        case MediaSource.gallery:
          final hasPermission = await _requestPermission(Permission.photos);
          if (!hasPermission) {
            throw Exception('Gallery permission denied');
          }
          pickedFile = await _imagePicker.pickVideo(
            source: ImageSource.gallery,
          );
          break;
      }

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick video: $e');
    }
  }

  Future<List<File>> pickMultipleImages() async {
    try {
      final hasPermission = await _requestPermission(Permission.photos);
      if (!hasPermission) {
        throw Exception('Gallery permission denied');
      }

      final pickedFiles = await _imagePicker.pickMultiImage(
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      return pickedFiles.map((file) => File(file.path)).toList();
    } catch (e) {
      throw Exception('Failed to pick multiple images: $e');
    }
  }
}
