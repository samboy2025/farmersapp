import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/message.dart';

class MediaGalleryScreen extends StatefulWidget {
  final List<Message> mediaMessages;

  const MediaGalleryScreen({
    super.key,
    required this.mediaMessages,
  });

  @override
  State<MediaGalleryScreen> createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends State<MediaGalleryScreen> {
  int _selectedTab = 0; // 0: Photos, 1: Videos, 2: Documents
  final List<String> _tabs = ['Photos', 'Videos', 'Documents'];

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
            Icons.close,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Media Gallery',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Tab selector
          _buildTabSelector(isDark),

          // Content
          Expanded(
            child: _buildContent(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = index == _selectedTab;
          return Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedTab = index;
                });
              },
              borderRadius: BorderRadius.circular(AppConfig.borderRadius),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? AppConfig.primaryColor.withOpacity(0.1) : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                ),
                child: Text(
                  _tabs[index],
                  style: TextStyle(
                    color: isSelected
                        ? AppConfig.primaryColor
                        : (isDark ? AppConfig.darkText : AppConfig.lightText),
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    final filteredMessages = _getFilteredMessages();

    if (filteredMessages.isEmpty) {
      return _buildEmptyState(isDark);
    }

    switch (_selectedTab) {
      case 0: // Photos
        return _buildPhotosGrid(filteredMessages, isDark);
      case 1: // Videos
        return _buildVideosList(filteredMessages, isDark);
      case 2: // Documents
        return _buildDocumentsList(filteredMessages, isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEmptyState(bool isDark) {
    final emptyIcons = [Icons.photo, Icons.videocam, Icons.description];
    final emptyMessages = [
      'No photos shared yet',
      'No videos shared yet',
      'No documents shared yet',
    ];

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                emptyIcons[_selectedTab],
                size: 48,
                color: AppConfig.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              emptyMessages[_selectedTab],
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Shared media will appear here',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosGrid(List<Message> messages, bool isDark) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return InkWell(
          onTap: () => _openPhotoViewer(message, messages, index),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
              image: message.fileName != null
                  ? DecorationImage(
                      image: NetworkImage('https://picsum.photos/200/200?random=$index'),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: message.fileName == null
                ? const Icon(
                    Icons.photo,
                    color: Colors.grey,
                    size: 32,
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildVideosList(List<Message> messages, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? AppConfig.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          ),
          child: ListTile(
            leading: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.videocam,
                color: Colors.grey,
                size: 32,
              ),
            ),
            title: Text(
              message.fileName ?? 'Video',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
              ),
            ),
            subtitle: Text(
              _formatFileSize(message.fileSize ?? 0),
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () => _playVideo(message),
            ),
            onTap: () => _openVideoPlayer(message),
          ),
        );
      },
    );
  }

  Widget _buildDocumentsList(List<Message> messages, bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isDark ? AppConfig.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _getFileColor(message.fileName ?? '').withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getFileIcon(message.fileName ?? ''),
                color: _getFileColor(message.fileName ?? ''),
                size: 24,
              ),
            ),
            title: Text(
              message.fileName ?? 'Document',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
              ),
            ),
            subtitle: Text(
              '${_formatFileSize(message.fileSize ?? 0)} • ${_formatDate(message.timestamp)}',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.download),
              onPressed: () => _downloadFile(message),
            ),
            onTap: () => _openDocument(message),
          ),
        );
      },
    );
  }

  List<Message> _getFilteredMessages() {
    return widget.mediaMessages.where((message) {
      switch (_selectedTab) {
        case 0: // Photos
          return message.type == MessageType.image;
        case 1: // Videos
          return message.type == MessageType.video;
        case 2: // Documents
          return message.type == MessageType.file;
        default:
          return false;
      }
    }).toList();
  }

  void _openPhotoViewer(Message message, List<Message> allPhotos, int initialIndex) {
    // Navigate to photo viewer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening photo viewer...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _playVideo(Message message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Playing video...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _openVideoPlayer(Message message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening video player...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _downloadFile(Message message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Downloading file...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _openDocument(Message message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening document...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes == 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    final i = (bytes.bitLength - 1) ~/ 10;
    return '${(bytes / (1 << (i * 10))).toStringAsFixed(1)} ${suffixes[i]}';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'txt':
        return Icons.text_snippet;
      case 'zip':
      case 'rar':
        return Icons.archive;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      case 'ppt':
      case 'pptx':
        return Colors.orange;
      case 'txt':
        return Colors.grey;
      case 'zip':
      case 'rar':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
