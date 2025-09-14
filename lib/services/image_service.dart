import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'permissions_service.dart';

/// ImageService provides comprehensive image handling functionality
/// including camera/gallery selection, compression, and validation.
///
/// Usage:
/// 1. Request permissions using PermissionsService
/// 2. Use pickFromCameraWithPermission() or pickFromGalleryWithPermission()
/// 3. Compress with compressImage() for optimization
/// 4. Validate with isValidImageFile()
/// 5. Use createCircularImagePreview() for UI display
class ImageService {
  static final ImagePicker _picker = ImagePicker();

  /// Pick image from camera
  static Future<File?> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  /// Pick image from camera with permission check
  static Future<File?> pickFromCameraWithPermission(BuildContext context) async {
    final hasPermission = await PermissionsService.requestCameraPermission(context);

    if (!hasPermission) {
      return null;
    }

    return await pickFromCamera();
  }

  /// Pick image from gallery
  static Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  /// Pick image from gallery with permission check
  static Future<File?> pickFromGalleryWithPermission(BuildContext context) async {
    final hasPermission = await PermissionsService.requestStoragePermission(context);

    if (!hasPermission) {
      return null;
    }

    return await pickFromGallery();
  }

  /// Resize image to square format for profile pictures
  static Future<File?> resizeImageToSquare(File imageFile, {int size = 400}) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(dir.path, 'resized_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 85,
        minWidth: size,
        minHeight: size,
      );

      if (result != null) {
        return File(result.path);
      }
      return imageFile; // Return original if resize fails
    } catch (e) {
      debugPrint('Error resizing image: $e');
      return imageFile;
    }
  }

  /// Compress image to reduce file size
  static Future<File?> compressImage(File imageFile) async {
    try {
      final dir = await getTemporaryDirectory();
      final targetPath = path.join(dir.path, 'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg');

      final result = await FlutterImageCompress.compressAndGetFile(
        imageFile.absolute.path,
        targetPath,
        quality: 80,
        minWidth: 800,
        minHeight: 800,
      );

      if (result != null) {
        return File(result.path);
      }
      return imageFile; // Return original if compression fails
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return imageFile;
    }
  }

  /// Get image file size in MB
  static double getFileSizeInMB(File file) {
    return file.lengthSync() / (1024 * 1024);
  }

  /// Validate image file
  static bool isValidImageFile(File file) {
    try {
      final extension = path.extension(file.path).toLowerCase();
      final validExtensions = ['.jpg', '.jpeg', '.png', '.webp'];

      if (!validExtensions.contains(extension)) {
        return false;
      }

      // Check file size (max 10MB)
      final sizeInMB = getFileSizeInMB(file);
      if (sizeInMB > 10.0) {
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Create a circular image widget for preview
  static Widget createCircularImagePreview({
    required File? imageFile,
    required String fallbackText,
    double radius = 50.0,
    Color backgroundColor = const Color(0xFF25D366),
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor.withValues(alpha: 0.1),
      backgroundImage: imageFile != null ? FileImage(imageFile) : null,
      child: imageFile == null
          ? Text(
              fallbackText,
              style: TextStyle(
                color: backgroundColor,
                fontSize: radius * 0.6,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  /// Complete image selection flow with processing
  static Future<File?> pickAndProcessImage(
    BuildContext context, {
    bool enableCropping = true,
    bool enableCompression = true,
    double maxFileSizeMB = 10.0,
  }) async {
    try {
      // Show source selection dialog
      final ImageSource? source = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Select Image Source'),
          content: const Text('Choose where to get the image from'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              child: const Text('Camera'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              child: const Text('Gallery'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );

      if (source == null) return null;

      // Request permissions
      final hasPermission = source == ImageSource.camera
          ? await PermissionsService.requestCameraPermission(context)
          : await PermissionsService.requestStoragePermission(context);

      if (!hasPermission) return null;

      // Pick image
      final imageFile = source == ImageSource.camera
          ? await pickFromCamera()
          : await pickFromGallery();

      if (imageFile == null) return null;

      // Validate image
      if (!isValidImageFile(imageFile)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid image file. Please select a valid image under 10MB.'),
            backgroundColor: Colors.red,
          ),
        );
        return null;
      }

      // Resize image if enabled (for better profile picture display)
      File? processedImage = imageFile;
      if (enableCropping) {
        final resizedImage = await resizeImageToSquare(imageFile);
        if (resizedImage != null) {
          processedImage = resizedImage;
        }
      }

      // Compress image if enabled
      if (enableCompression) {
        final compressedImage = await compressImage(processedImage);
        if (compressedImage != null) {
          processedImage = compressedImage;
        }
      }

      return processedImage;
    } catch (e) {
      debugPrint('Error in pickAndProcessImage: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to process image: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return null;
    }
  }

  /// Show image picker bottom sheet
  static void showImagePickerBottomSheet(
    BuildContext context, {
    required VoidCallback onCameraTap,
    required VoidCallback onGalleryTap,
    VoidCallback? onRemoveTap,
    bool showRemoveOption = false,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Set group photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildImageOption(
                    icon: Icons.camera_alt,
                    title: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      onCameraTap();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildImageOption(
                    icon: Icons.photo_library,
                    title: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      onGalleryTap();
                    },
                  ),
                ),
              ],
            ),
            if (showRemoveOption) ...[
              const SizedBox(height: 12),
              _buildImageOption(
                icon: Icons.delete,
                title: 'Remove Photo',
                onTap: () {
                  Navigator.pop(context);
                  onRemoveTap?.call();
                },
                isDestructive: true,
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _buildImageOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isDestructive
              ? Colors.red.withValues(alpha: 0.1)
              : const Color(0xFF25D366).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.2)
                : const Color(0xFF25D366).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : const Color(0xFF25D366),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.red : const Color(0xFF25D366),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
