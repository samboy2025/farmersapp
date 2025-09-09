import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' as img_picker;
import 'package:file_picker/file_picker.dart';
import '../../../config/app_config.dart';
import '../../../models/message.dart';
import '../../../services/media_picker_service.dart';

class AttachmentModalBottomSheet extends StatelessWidget {
  final Function(MessageType, String, String) onAttachmentSelected;

  const AttachmentModalBottomSheet({
    super.key,
    required this.onAttachmentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: const EdgeInsets.all(AppConfig.padding),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title
          Text(
            'Share',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          
          // Attachment options grid
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
              _buildAttachmentOption(
                context,
                icon: Icons.photo,
                label: 'Gallery',
                color: Colors.green,
                  onTap: () => _selectImage(context, img_picker.ImageSource.gallery),
              ),
              _buildAttachmentOption(
                context,
                icon: Icons.camera_alt,
                label: 'Camera',
                color: Colors.blue,
                  onTap: () => _selectImage(context, img_picker.ImageSource.camera),
              ),
              _buildAttachmentOption(
                context,
                icon: Icons.attach_file,
                label: 'Document',
                color: Colors.orange,
                onTap: () => _selectDocument(context),
              ),
            ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAttachmentOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConfig.borderRadius),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: Icon(
              icon,
              color: color,
              size: 32,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _selectImage(BuildContext context, img_picker.ImageSource source) async {
    try {
      final mediaPicker = MediaPickerService();
      final mediaSource = source == img_picker.ImageSource.camera
          ? MediaSource.camera
          : MediaSource.gallery;

      final pickedFile = await mediaPicker.pickImage(mediaSource);

      if (pickedFile != null) {
    onAttachmentSelected(
      MessageType.image,
          pickedFile.path,
          pickedFile.path.split('/').last,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
            content: const Text('Image selected successfully'),
            backgroundColor: AppConfig.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
      ),
    );
  }
    } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select image: $e'),
          backgroundColor: AppConfig.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }


  Future<void> _selectDocument(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'ppt', 'pptx', 'xls', 'xlsx'],
      );

      if (result != null) {
        final file = result.files.first;

    onAttachmentSelected(
          MessageType.file,
          file.path ?? '',
          file.name,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Document "${file.name}" selected successfully'),
            backgroundColor: AppConfig.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to select document: $e'),
          backgroundColor: AppConfig.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
      ),
    );
  }
}

}


