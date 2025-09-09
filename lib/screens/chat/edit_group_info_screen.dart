import 'dart:io';
import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/group.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';

class EditGroupInfoScreen extends StatefulWidget {
  final Group group;

  const EditGroupInfoScreen({
    super.key,
    required this.group,
  });

  @override
  State<EditGroupInfoScreen> createState() => _EditGroupInfoScreenState();
}

class _EditGroupInfoScreenState extends State<EditGroupInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _groupPicture;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.group.name;
    _descriptionController.text = widget.group.description ?? '';
    _groupPicture = widget.group.groupPicture;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.darkBackground : AppConfig.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Edit Group Info',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: Text(
              'Save',
              style: TextStyle(
                color: AppConfig.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group Picture Section
              _buildPictureSection(isDark),

              const SizedBox(height: 24),

              // Group Name Section
              _buildNameSection(isDark),

              const SizedBox(height: 24),

              // Group Description Section
              _buildDescriptionSection(isDark),

              const SizedBox(height: 32),

              // Privacy Settings
              _buildPrivacySection(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPictureSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Group Picture',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor,
                  borderRadius: BorderRadius.circular(60),
                  image: _groupPicture != null
                      ? DecorationImage(
                          image: NetworkImage(_groupPicture!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _groupPicture == null
                    ? const Icon(
                        Icons.groups,
                        color: Colors.white,
                        size: 60,
                      )
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppConfig.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? AppConfig.darkSurface : Colors.white,
                      width: 3,
                    ),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                    onPressed: _changePicture,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNameSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Group Name',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Enter group name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            ),
            filled: true,
            fillColor: isDark ? AppConfig.darkSurface : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Group name cannot be empty';
            }
            if (value.length > 25) {
              return 'Group name cannot exceed 25 characters';
            }
            return null;
          },
          maxLength: 25,
        ),
        const SizedBox(height: 8),
        Text(
          '${_nameController.text.length}/25 characters',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Group Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Describe your group (optional)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            ),
            filled: true,
            fillColor: isDark ? AppConfig.darkSurface : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (value != null && value.length > 500) {
              return 'Description cannot exceed 500 characters';
            }
            return null;
          },
          maxLength: 500,
        ),
        const SizedBox(height: 8),
        Text(
          '${_descriptionController.text.length}/500 characters',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppConfig.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          ),
          child: Column(
            children: [
              _buildPrivacyOption(
                title: 'Make group private',
                subtitle: 'Only members can see the group and its messages',
                value: true, // Default to private
                onChanged: (value) {
                  // Handle privacy change
                },
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _buildPrivacyOption(
                title: 'Require admin approval',
                subtitle: 'New members need admin approval to join',
                value: false,
                onChanged: (value) {
                  // Handle approval requirement
                },
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyOption({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppConfig.primaryColor,
        ),
      ],
    );
  }

  void _changePicture() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppConfig.darkSurface
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.photo_library,
                  color: AppConfig.primaryColor,
                ),
              ),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickFromGallery();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppConfig.primaryColor,
                ),
              ),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _takePhoto();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
              title: const Text('Remove Picture'),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _groupPicture = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _pickFromGallery() {
    // Simulate image picker
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Gallery picker coming soon'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _takePhoto() {
    // Simulate camera
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Camera coming soon'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Group info updated successfully'),
              backgroundColor: AppConfig.successColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );

          Navigator.of(context).pop();
        }
      });
    }
  }
}
