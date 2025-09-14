import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionsService {
  /// Request camera permission
  static Future<bool> requestCameraPermission(BuildContext context) async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied || status.isPermanentlyDenied) {
      final result = await Permission.camera.request();

      if (result.isGranted) {
        return true;
      }

      if (result.isPermanentlyDenied) {
        await _showPermissionDialog(
          context,
          'Camera Permission Required',
          'Camera permission is required to take photos. Please enable it in app settings.',
        );
      }
    }

    return false;
  }

  /// Request storage/gallery permission
  static Future<bool> requestStoragePermission(BuildContext context) async {
    final status = await Permission.photos.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied || status.isPermanentlyDenied) {
      final result = await Permission.photos.request();

      if (result.isGranted) {
        return true;
      }

      if (result.isPermanentlyDenied) {
        await _showPermissionDialog(
          context,
          'Gallery Permission Required',
          'Gallery permission is required to select photos. Please enable it in app settings.',
        );
      }
    }

    return false;
  }

  /// Request both camera and storage permissions
  static Future<Map<String, bool>> requestImagePermissions(BuildContext context) async {
    final cameraGranted = await requestCameraPermission(context);
    final storageGranted = await requestStoragePermission(context);

    return {
      'camera': cameraGranted,
      'storage': storageGranted,
    };
  }

  /// Show permission settings dialog
  static Future<void> _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Check if all image permissions are granted
  static Future<bool> hasImagePermissions() async {
    final cameraStatus = await Permission.camera.status;
    final storageStatus = await Permission.photos.status;

    return cameraStatus.isGranted && storageStatus.isGranted;
  }

  /// Get permission status for debugging
  static Future<Map<String, String>> getPermissionStatus() async {
    final cameraStatus = await Permission.camera.status;
    final storageStatus = await Permission.photos.status;

    return {
      'camera': cameraStatus.toString(),
      'storage': storageStatus.toString(),
    };
  }
}
