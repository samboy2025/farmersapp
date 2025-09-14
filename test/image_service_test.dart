import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../lib/services/image_service.dart';

// Mock classes for testing
class MockBuildContext extends Mock implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ImageService Tests', () {
    test('isValidImageFile returns true for valid image', () {
      // Create a temporary file for testing
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/test_image.jpg');
      testFile.writeAsBytesSync(List.generate(1024, (index) => index % 256)); // Small dummy content

      final result = ImageService.isValidImageFile(testFile);

      expect(result, isTrue);

      // Clean up
      testFile.deleteSync();
    });

    test('isValidImageFile returns false for invalid file type', () {
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/test_document.txt');
      testFile.writeAsBytesSync([72, 101, 108, 108, 111]); // "Hello"

      final result = ImageService.isValidImageFile(testFile);

      expect(result, isFalse);

      // Clean up
      testFile.deleteSync();
    });

    test('getFileSizeInMB returns correct size', () {
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/test_size.jpg');
      final oneMBData = List.generate(1024 * 1024, (index) => index % 256);
      testFile.writeAsBytesSync(oneMBData);

      final size = ImageService.getFileSizeInMB(testFile);

      expect(size, closeTo(1.0, 0.1));

      // Clean up
      testFile.deleteSync();
    });

    test('createCircularImagePreview creates widget correctly', () {
      final result = ImageService.createCircularImagePreview(
        imageFile: null,
        fallbackText: 'Test',
        radius: 50,
      );

      expect(result, isA<CircleAvatar>());
    });
  });
}
