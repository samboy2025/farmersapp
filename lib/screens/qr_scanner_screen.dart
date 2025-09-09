import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../services/mock_data_service.dart';
import '../models/user.dart';
import '../models/chat.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera preview placeholder (simulated)
            Container(
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.camera_alt,
                      size: 64,
                      color: Colors.white.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Camera Preview',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Scanner overlay
            _buildScannerOverlay(),

            // Header
            _buildHeader(),

            // Bottom controls
            _buildBottomControls(),

            // Scanning animation
            _buildScanAnimation(),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerOverlay() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = constraints.maxWidth * 0.7;
        final scanAreaTop = (constraints.maxHeight - scanAreaSize) / 2 - 50;

        return Stack(
          children: [
            // Semi-transparent overlay
            Container(
              color: Colors.black.withOpacity(0.5),
            ),

            // Cut out the scan area
            Positioned(
              top: scanAreaTop,
              left: (constraints.maxWidth - scanAreaSize) / 2,
              child: Container(
                width: scanAreaSize,
                height: scanAreaSize,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppConfig.primaryColor,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
            ),

            // Corner brackets
            Positioned(
              top: scanAreaTop - 2,
              left: (constraints.maxWidth - scanAreaSize) / 2 - 2,
              child: _buildCornerBracket(0),
            ),
            Positioned(
              top: scanAreaTop - 2,
              right: (constraints.maxWidth - scanAreaSize) / 2 - 2,
              child: _buildCornerBracket(1),
            ),
            Positioned(
              bottom: constraints.maxHeight - scanAreaTop - scanAreaSize - 2,
              left: (constraints.maxWidth - scanAreaSize) / 2 - 2,
              child: _buildCornerBracket(2),
            ),
            Positioned(
              bottom: constraints.maxHeight - scanAreaTop - scanAreaSize - 2,
              right: (constraints.maxWidth - scanAreaSize) / 2 - 2,
              child: _buildCornerBracket(3),
            ),

            // Instructions
            Positioned(
              top: scanAreaTop + scanAreaSize + 20,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    'Scan QR Code',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Point your camera at a QR code to scan',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCornerBracket(int position) {
    // Position: 0=top-left, 1=top-right, 2=bottom-left, 3=bottom-right
    final isTop = position < 2;
    final isLeft = position % 2 == 0;

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border.all(color: AppConfig.primaryColor),
        borderRadius: BorderRadius.only(
          topLeft: isTop && isLeft ? const Radius.circular(12) : Radius.zero,
          topRight: isTop && !isLeft ? const Radius.circular(12) : Radius.zero,
          bottomLeft: !isTop && isLeft ? const Radius.circular(12) : Radius.zero,
          bottomRight: !isTop && !isLeft ? const Radius.circular(12) : Radius.zero,
        ),
      ),
      child: CustomPaint(
        painter: CornerBracketPainter(
          color: AppConfig.primaryColor,
          isTop: isTop,
          isLeft: isLeft,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close,
              color: Colors.white,
              size: 28,
            ),
          ),
          const Expanded(
            child: Text(
              'Scan QR Code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            onPressed: _toggleFlash,
            icon: Icon(
              _isFlashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  Icons.photo_library,
                  'Gallery',
                  _openGallery,
                ),
                _buildControlButton(
                  Icons.qr_code,
                  'My QR',
                  _showMyQR,
                ),
                _buildControlButton(
                  Icons.flip_camera_ios,
                  'Flip',
                  _flipCamera,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Simulate successful scan
            ElevatedButton(
              onPressed: _simulateScanSuccess,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Simulate Scan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(IconData icon, String label, VoidCallback onTap) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: IconButton(
            onPressed: onTap,
            icon: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildScanAnimation() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scanAreaSize = constraints.maxWidth * 0.7;
        final scanAreaTop = (constraints.maxHeight - scanAreaSize) / 2 - 50;

        return AnimatedBuilder(
          animation: _scanAnimation,
          builder: (context, child) {
            return Positioned(
              top: scanAreaTop + (_scanAnimation.value * scanAreaSize),
              left: (constraints.maxWidth - scanAreaSize) / 2,
              child: Container(
                width: scanAreaSize,
                height: 2,
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppConfig.primaryColor.withOpacity(0.5),
                      blurRadius: 4,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _toggleFlash() {
    setState(() {
      _isFlashOn = !_isFlashOn;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFlashOn ? 'Flash turned on' : 'Flash turned off'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _flipCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isFrontCamera ? 'Front camera' : 'Back camera'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _openGallery() {
    // Simulate opening gallery and selecting QR image
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening gallery to scan QR code...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );

    // Simulate successful QR scan from gallery
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _simulateScanSuccess();
      }
    });
  }

  void _showMyQR() {
    _showMyQRDialog();
  }

  void _simulateScanSuccess() {
    // Simulate finding a user/contact
    final mockUsers = MockDataService.users;
    final randomUser = mockUsers[DateTime.now().millisecondsSinceEpoch % mockUsers.length];

    _showScanResultDialog(randomUser);
  }

  void _showMyQRDialog() {
    final currentUser = MockDataService.currentUser;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? AppConfig.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'My QR Code',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // QR Code placeholder
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.qr_code,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currentUser.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      currentUser.phoneNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _shareMyQR();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Share'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showScanResultDialog(User user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: isDark ? AppConfig.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                size: 64,
                color: AppConfig.successColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Contact Found!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'We found ${user.name} in our database.',
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppConfig.darkCard : AppConfig.lightCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppConfig.primaryColor,
                      child: Text(
                        user.name[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppConfig.darkText : AppConfig.lightText,
                            ),
                          ),
                          Text(
                            user.phoneNumber,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop(); // Close scanner
                        _startChatWithUser(user);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Message'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startChatWithUser(User user) {
    // Create a chat with the scanned user
    final chat = Chat(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: user.name,
      participants: [MockDataService.currentUser, user],
      lastMessage: null,
      unreadCount: 0,
      lastActivity: DateTime.now(),
      createdAt: DateTime.now(),
    );

    // Navigate to chat screen
    Navigator.pushNamed(
      context,
      '/chat',
      arguments: chat,
    );
  }

  void _shareMyQR() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sharing your QR code...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

class CornerBracketPainter extends CustomPainter {
  final Color color;
  final bool isTop;
  final bool isLeft;

  CornerBracketPainter({
    required this.color,
    required this.isTop,
    required this.isLeft,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(size.width, size.height);
      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(size.width, 0);
      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
