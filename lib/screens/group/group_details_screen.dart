import 'dart:io';
import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../models/group.dart';
import '../../services/mock_data_service.dart';
import '../../services/image_service.dart';

class GroupDetailsScreen extends StatefulWidget {
  final List<User> selectedParticipants;
  final VoidCallback onGroupCreated;

  const GroupDetailsScreen({
    super.key,
    required this.selectedParticipants,
    required this.onGroupCreated,
  });

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  File? _selectedImageFile;
  String? _groupImageUrl;
  bool _isCreating = false;
  bool _isProcessingImage = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _showImagePicker() {
    ImageService.showImagePickerBottomSheet(
      context,
      onCameraTap: _handleCameraSelection,
      onGalleryTap: _handleGallerySelection,
      onRemoveTap: _handleRemoveImage,
      showRemoveOption: _selectedImageFile != null,
    );
  }

  Future<void> _handleCameraSelection() async {
    setState(() {
      _isProcessingImage = true;
    });

    try {
      final imageFile = await ImageService.pickFromCameraWithPermission(context);

      if (imageFile != null) {
        await _processSelectedImage(imageFile);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to access camera');
    } finally {
      setState(() {
        _isProcessingImage = false;
      });
    }
  }

  Future<void> _handleGallerySelection() async {
    setState(() {
      _isProcessingImage = true;
    });

    try {
      final imageFile = await ImageService.pickFromGalleryWithPermission(context);

      if (imageFile != null) {
        await _processSelectedImage(imageFile);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to access gallery');
    } finally {
      setState(() {
        _isProcessingImage = false;
      });
    }
  }

  Future<void> _processSelectedImage(File imageFile) async {
    try {
      // Validate image
      if (!ImageService.isValidImageFile(imageFile)) {
        _showErrorSnackBar('Invalid image file. Please select a valid image under 10MB.');
        return;
      }

      // Resize image for better profile display
      final resizedImage = await ImageService.resizeImageToSquare(imageFile);
      if (resizedImage == null) {
        _showErrorSnackBar('Failed to process image');
        return;
      }

      // Compress image
      final compressedImage = await ImageService.compressImage(resizedImage);
      if (compressedImage == null) {
        _showErrorSnackBar('Failed to process image');
        return;
      }

      setState(() {
        _selectedImageFile = compressedImage;
        _groupImageUrl = compressedImage.path; // Store local path
      });

      _showSuccessSnackBar('Group photo updated successfully!');
    } catch (e) {
      _showErrorSnackBar('Failed to process image: $e');
    }
  }

  void _handleRemoveImage() {
    setState(() {
      _selectedImageFile = null;
      _groupImageUrl = null;
    });
    _showSuccessSnackBar('Group photo removed');
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _createGroup() async {
    if (_groupNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a group name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    // Simulate group creation
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      // Create the group (in a real app, this would save to backend)
      final newGroup = Group(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _groupNameController.text.trim(),
        description: '',
        groupPicture: _selectedImageFile?.path ?? _groupImageUrl, // Use the processed image file path
        members: [...widget.selectedParticipants, MockDataService.currentUser],
        admins: [MockDataService.currentUser], // Creator is admin by default
        createdBy: MockDataService.currentUser,
        lastMessage: null,
        lastActivity: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Group "${newGroup.name}" created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Call the callback and navigate back
      widget.onGroupCreated();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppConfig.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New group',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isCreating ? null : _createGroup,
            child: Text(
              _isCreating ? 'Creating...' : 'Create',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Add bottom padding for potential FAB
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group avatar section
            Center(
              child: GestureDetector(
                onTap: _isProcessingImage ? null : _showImagePicker,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Main avatar
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _selectedImageFile != null
                              ? AppConfig.primaryColor.withValues(alpha: 0.3)
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: _isProcessingImage
                          ? const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF25D366)),
                            )
                          : ImageService.createCircularImagePreview(
                              imageFile: _selectedImageFile,
                              fallbackText: 'G',
                              radius: 50,
                              backgroundColor: AppConfig.primaryColor,
                            ),
                    ),

                    // Camera/Edit icon
                    if (!_isProcessingImage)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppConfig.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _selectedImageFile != null ? Icons.edit : Icons.camera_alt,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),

                    // Overlay for processing state
                    if (_isProcessingImage)
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                        child: const Icon(
                          Icons.hourglass_top,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Image info (if image is selected)
            if (_selectedImageFile != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.image,
                      size: 20,
                      color: AppConfig.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Photo selected (${(ImageService.getFileSizeInMB(_selectedImageFile!) * 100).round() / 100} MB)',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConfig.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _handleRemoveImage,
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                        color: Colors.grey,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 32),

            // Group name input
            const Text(
              'Group name',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _groupNameController,
              decoration: InputDecoration(
                hintText: 'Enter group name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppConfig.primaryColor),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLength: 25,
              buildCounter: (context, {required currentLength, required isFocused, maxLength}) {
                return Text(
                  '$currentLength/$maxLength',
                  style: TextStyle(
                    color: currentLength > maxLength! ? Colors.red : Colors.grey,
                    fontSize: 12,
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // Selected participants preview
            Text(
              'Participants (${widget.selectedParticipants.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Participants list (horizontal scroll)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 85), // Slightly more flexible
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.selectedParticipants.length,
                itemBuilder: (context, index) {
                  final user = widget.selectedParticipants[index];
                  return Container(
                    width: 55, // Slightly smaller to fit more
                    margin: const EdgeInsets.only(right: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 20, // Reduced from 24 to prevent overflow
                          backgroundColor: AppConfig.primaryColor.withValues(alpha: 0.1),
                          backgroundImage: user.profilePicture != null
                              ? NetworkImage(user.profilePicture!)
                              : null,
                          child: user.profilePicture == null
                              ? Text(
                                  user.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: AppConfig.primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14, // Reduced font size
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 2), // Reduced spacing
                        Flexible(
                          child: Text(
                            user.name.split(' ').first,
                            style: const TextStyle(
                              fontSize: 11, // Reduced font size
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
