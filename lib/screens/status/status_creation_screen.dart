import 'package:flutter/material.dart';
import 'dart:io';
import '../../config/app_config.dart';
import '../../models/status.dart';
import '../../services/mock_data_service.dart';
import '../../services/status_service.dart';
import 'status_text_formatting_screen.dart';

class StatusCreationScreen extends StatefulWidget {
  const StatusCreationScreen({super.key});

  @override
  State<StatusCreationScreen> createState() => _StatusCreationScreenState();
}

class _StatusCreationScreenState extends State<StatusCreationScreen> {
  final TextEditingController _statusController = TextEditingController();
  final StatusService _statusService = StatusService();
  
  File? _selectedMediaFile;
  bool _isMediaSelected = false;
  bool _isCreating = false;
  StatusType _selectedType = StatusType.text;
  StatusPrivacy _selectedPrivacy = StatusPrivacy.contactsOnly;
  List<String> _allowedViewers = [];

  @override
  void initState() {
    super.initState();
    _statusService.initialize();
  }

  @override
  void dispose() {
    _statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    
    return Scaffold(
      backgroundColor: AppConfig.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            _buildTopNavigation(isTablet),
            
            // Main Content Area
            Expanded(
              child: _buildContentByType(isTablet),
            ),
            
            // Bottom Action Bar
            _buildActionBar(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavigation(bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 16 : 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: const Color(0xFF667781),
            constraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            splashRadius: 20,
          ),
          
          // Title
          Expanded(
            child: Text(
              'Create status',
              style: TextStyle(
                fontSize: isTablet ? 22 : 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111B21),
              ),
            ),
          ),
          
          // More options
          IconButton(
            onPressed: _showMoreOptions,
            icon: const Icon(Icons.more_vert),
            color: const Color(0xFF667781),
            constraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildContentByType(bool isTablet) {
    switch (_selectedType) {
      case StatusType.text:
        return _buildTextStatusContent(isTablet);
      case StatusType.image:
        return _buildImageStatusContent(isTablet);
      case StatusType.video:
        return _buildVideoStatusContent(isTablet);
    }
  }

  Widget _buildTextStatusContent(bool isTablet) {
    return Column(
      children: [
        // Type selector tabs
        _buildTypeSelector(isTablet),
        
        SizedBox(height: isTablet ? 24 : 16),
        
        // Text input area
        Expanded(
          child: Container(
            margin: EdgeInsets.all(isTablet ? 24 : 16),
            padding: EdgeInsets.all(isTablet ? 32 : 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: TextField(
                    controller: _statusController,
                    maxLines: null,
                    expands: true,
                    textAlign: TextAlign.center,
                    maxLength: 300,
                    style: TextStyle(
                      fontSize: isTablet ? 22 : 18,
                      height: 1.4,
                      color: const Color(0xFF111B21),
                    ),
                    decoration: InputDecoration(
                      hintText: 'What\'s on your mind?',
                      hintStyle: TextStyle(
                        color: const Color(0xFF667781),
                        fontSize: isTablet ? 22 : 18,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                    onChanged: (value) => setState(() {}),
                  ),
                ),
                
                // Character count
                Text(
                  '${_statusController.text.length}/300',
                  style: TextStyle(
                    color: _statusController.text.length > 280 
                        ? AppConfig.errorColor 
                        : const Color(0xFF667781),
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageStatusContent(bool isTablet) {
    return Column(
      children: [
        // Type selector tabs
        _buildTypeSelector(isTablet),
        
        const SizedBox(height: 16),
        
        // Image selection area
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: _isMediaSelected && _selectedMediaFile != null
                ? Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(_selectedMediaFile!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Caption input
                      TextField(
                        controller: _statusController,
                        maxLength: 100,
                        decoration: const InputDecoration(
                          hintText: 'Add a caption...',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.photo_camera_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Select or take a photo',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            onPressed: _selectFromGallery,
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConfig.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: _takePhoto,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Camera'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppConfig.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoStatusContent(bool isTablet) {
    return Column(
      children: [
        // Type selector tabs
        _buildTypeSelector(isTablet),
        
        const SizedBox(height: 16),
        
        // Video selection area
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: _isMediaSelected && _selectedMediaFile != null
                ? Column(
                    children: [
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.black,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.play_circle_fill,
                              size: 64,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Caption input
                      TextField(
                        controller: _statusController,
                        maxLength: 100,
                        decoration: const InputDecoration(
                          hintText: 'Add a caption...',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videocam_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Record or select a video',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _recordVideo,
                        icon: const Icon(Icons.videocam),
                        label: const Text('Record Video'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConfig.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector(bool isTablet) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _buildTypeTab('Text', StatusType.text, Icons.text_fields, isTablet),
          _buildTypeTab('Photo', StatusType.image, Icons.photo_camera, isTablet),
          _buildTypeTab('Video', StatusType.video, Icons.videocam, isTablet),
        ],
      ),
    );
  }

  Widget _buildTypeTab(String label, StatusType type, IconData icon, bool isTablet) {
    final isSelected = _selectedType == type;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 16 : 12,
            horizontal: isTablet ? 12 : 8,
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppConfig.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isTablet ? 20 : 18,
                color: isSelected ? Colors.white : const Color(0xFF667781),
              ),
              SizedBox(width: isTablet ? 10 : 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF667781),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Privacy selector
          Expanded(
            child: InkWell(
              onTap: _showPrivacyOptions,
              borderRadius: BorderRadius.circular(30),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 20 : 16, 
                  vertical: isTablet ? 16 : 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Icon(
                      _getPrivacyIcon(),
                      size: isTablet ? 20 : 18,
                      color: const Color(0xFF667781),
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    Text(
                      _getPrivacyText(),
                      style: TextStyle(
                        color: const Color(0xFF667781),
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: const Color(0xFF667781),
                      size: isTablet ? 20 : 18,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SizedBox(width: isTablet ? 20 : 16),
          
          // Send button
          Container(
            width: isTablet ? 64 : 56,
            height: isTablet ? 64 : 56,
            child: FloatingActionButton(
              onPressed: _canCreateStatus() ? _createStatus : null,
              backgroundColor: _canCreateStatus() 
                  ? AppConfig.primaryColor 
                  : const Color(0xFFE5E5E5),
              elevation: _canCreateStatus() ? 4 : 0,
              child: _isCreating
                  ? SizedBox(
                      width: isTablet ? 24 : 20,
                      height: isTablet ? 24 : 20,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      Icons.send, 
                      color: _canCreateStatus() 
                          ? Colors.white 
                          : const Color(0xFF667781),
                      size: isTablet ? 28 : 24,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.font_download),
              title: const Text('Text Formatting'),
              onTap: () {
                Navigator.pop(context);
                _showTextFormatting();
              },
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Background Colors'),
              onTap: () {
                Navigator.pop(context);
                _showColorPicker();
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('Disappearing Messages'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showTextFormatting() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatusTextFormattingScreen(
          initialText: _statusController.text,
          onFormattingComplete: (text, formatting) {
            setState(() {
              _statusController.text = text;
              // Store formatting options for later use
              // This would be applied when creating the status
            });
          },
        ),
      ),
    );
  }

  void _showColorPicker() {
    // Show a color picker dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Background Color'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Colors.white,
                Colors.black,
                Colors.red,
                Colors.blue,
                Colors.green,
                Colors.yellow,
                Colors.purple,
                Colors.pink,
                Colors.orange,
                Colors.teal,
              ].map((color) {
                return InkWell(
                  onTap: () {
                    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Background color set to ${color.toString()}'),
                        backgroundColor: AppConfig.primaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  bool _canCreateStatus() {
    if (_selectedType == StatusType.text) {
      return _statusController.text.trim().isNotEmpty;
    } else {
      return _isMediaSelected && _selectedMediaFile != null;
    }
  }

  IconData _getPrivacyIcon() {
    switch (_selectedPrivacy) {
      case StatusPrivacy.public:
        return Icons.public;
      case StatusPrivacy.contactsOnly:
        return Icons.people;
      case StatusPrivacy.custom:
        return Icons.people_outline;
    }
  }





  String _getPrivacyText() {
    switch (_selectedPrivacy) {
      case StatusPrivacy.public:
        return 'Everyone';
      case StatusPrivacy.contactsOnly:
        return 'My contacts';
      case StatusPrivacy.custom:
        return 'Custom';
    }
  }

  void _selectFromGallery() async {
    final file = await _statusService.pickImageFromGallery();
    if (file != null) {
      setState(() {
        _selectedMediaFile = file;
        _isMediaSelected = true;
        _selectedType = StatusType.image;
      });
    }
  }

  void _takePhoto() async {
    final file = await _statusService.takePhotoWithCamera();
    if (file != null) {
      setState(() {
        _selectedMediaFile = file;
        _isMediaSelected = true;
        _selectedType = StatusType.image;
      });
    }
  }

  void _recordVideo() async {
    final file = await _statusService.recordVideo();
    if (file != null) {
      setState(() {
        _selectedMediaFile = file;
        _isMediaSelected = true;
        _selectedType = StatusType.video;
      });
    }
  }



  void _showPrivacyOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Who can see your status?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildPrivacyOption(
              icon: Icons.public,
              title: 'Everyone',
              subtitle: 'Anyone can see your status',
              isSelected: _selectedPrivacy == StatusPrivacy.public,
              onTap: () => _updatePrivacy(StatusPrivacy.public),
            ),
            _buildPrivacyOption(
              icon: Icons.people,
              title: 'My contacts',
              subtitle: 'All your contacts can see your status',
              isSelected: _selectedPrivacy == StatusPrivacy.contactsOnly,
              onTap: () => _updatePrivacy(StatusPrivacy.contactsOnly),
            ),
            _buildPrivacyOption(
              icon: Icons.people_outline,
              title: 'Custom',
              subtitle: 'Choose specific contacts',
              isSelected: _selectedPrivacy == StatusPrivacy.custom,
              onTap: () => _updatePrivacy(StatusPrivacy.custom),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppConfig.primaryColor : Colors.grey,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: AppConfig.primaryColor,
            )
          : null,
      onTap: onTap,
    );
  }

  void _updatePrivacy(StatusPrivacy privacy) {
    setState(() {
      _selectedPrivacy = privacy;
    });
    Navigator.pop(context);
  }

  void _createStatus() async {
    if (_statusController.text.trim().isEmpty && !_isMediaSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some content to your status'),
          backgroundColor: AppConfig.errorColor,
        ),
      );
      return;
    }

    setState(() {
      _isCreating = true;
    });

    try {
      Status? status;
      final currentUser = MockDataService.currentUser;

      if (_isMediaSelected && _selectedMediaFile != null) {
        status = await _statusService.createMediaStatus(
          mediaFile: _selectedMediaFile!,
          author: currentUser,
          caption: _statusController.text.trim().isEmpty ? null : _statusController.text.trim(),
          privacy: _selectedPrivacy,
          allowedViewers: _allowedViewers,
        );
      } else {
        status = await _statusService.createTextStatus(
          text: _statusController.text.trim(),
          author: currentUser,
          privacy: _selectedPrivacy,
          allowedViewers: _allowedViewers,
        );
      }

      if (status != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status created successfully!'),
            backgroundColor: AppConfig.successColor,
          ),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Failed to create status');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create status: $e'),
            backgroundColor: AppConfig.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCreating = false;
        });
      }
    }
  }
}
