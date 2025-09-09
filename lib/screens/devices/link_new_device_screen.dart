import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/app_config.dart';

class LinkNewDeviceScreen extends StatefulWidget {
  const LinkNewDeviceScreen({super.key});

  @override
  State<LinkNewDeviceScreen> createState() => _LinkNewDeviceScreenState();
}

class _LinkNewDeviceScreenState extends State<LinkNewDeviceScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isGeneratingQR = true;
  String _deviceLinkCode = '';
  int _timeLeft = 300; // 5 minutes
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _generateLinkCode();
    _startTimer();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _generateLinkCode() {
    setState(() {
      _isGeneratingQR = true;
    });

    // Simulate QR code generation
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isGeneratingQR = false;
          _deviceLinkCode = 'CW-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
          _timeLeft = 300;
          _isExpired = false;
        });
      }
    });
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && !_isExpired) {
        setState(() {
          _timeLeft--;
          if (_timeLeft <= 0) {
            _isExpired = true;
          } else {
            _startTimer();
          }
        });
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
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
            Icons.close,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Link New Device',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Card
            _buildStatusCard(isDark),

            const SizedBox(height: 24),

            // QR Code Section
            if (!_isExpired) ...[
              _buildQRSection(isDark),
              const SizedBox(height: 24),
            ],

            // Instructions
            _buildInstructions(isDark),

            const SizedBox(height: 24),

            // Alternative Methods
            _buildAlternativeMethods(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppConfig.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _isExpired ? Colors.red.withOpacity(0.1) : AppConfig.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isExpired ? Icons.timer_off : Icons.devices,
                  color: _isExpired ? Colors.red : AppConfig.primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _isExpired ? 'Code Expired' : 'Ready to Link',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _isExpired
                    ? 'The linking code has expired. Generate a new one to continue.'
                    : 'Scan the QR code or enter the code on your other device',
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
      ),
    );
  }

  Widget _buildQRSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: Column(
        children: [
          // QR Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: _isGeneratingQR
                ? const SizedBox(
                    width: 200,
                    height: 200,
                    child: CircularProgressIndicator(
                      color: AppConfig.primaryColor,
                    ),
                  )
                : QrImageView(
                    data: 'chatwave://link-device/$_deviceLinkCode',
                    version: QrVersions.auto,
                    size: 200,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
          ),

          const SizedBox(height: 16),

          // Code Display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppConfig.darkCard : AppConfig.lightCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _deviceLinkCode,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppConfig.darkText : AppConfig.lightText,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () => _copyCode(),
                  color: AppConfig.primaryColor,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer,
                size: 16,
                color: _timeLeft < 60 ? Colors.red : AppConfig.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Expires in ${_formatTime(_timeLeft)}',
                style: TextStyle(
                  fontSize: 14,
                  color: _timeLeft < 60 ? Colors.red : AppConfig.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Refresh Button
          TextButton.icon(
            onPressed: _generateLinkCode,
            icon: const Icon(Icons.refresh),
            label: const Text('Generate New Code'),
            style: TextButton.styleFrom(
              foregroundColor: AppConfig.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline,
                  color: AppConfig.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'How to link your device',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInstructionStep(
            '1',
            'Open ChatWave on your other device',
            isDark,
          ),
          _buildInstructionStep(
            '2',
            'Go to Settings > Linked Devices',
            isDark,
          ),
          _buildInstructionStep(
            '3',
            'Tap "Link a Device"',
            isDark,
          ),
          _buildInstructionStep(
            '4',
            'Scan this QR code or enter the code',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppConfig.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeMethods(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alternative Methods',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppConfig.darkText : AppConfig.lightText,
            ),
          ),
          const SizedBox(height: 16),
          _buildAlternativeOption(
            icon: Icons.phone_android,
            title: 'Link via Phone Number',
            subtitle: 'Use your phone number to link devices',
            onTap: () => _linkViaPhone(),
            isDark: isDark,
          ),
          _buildAlternativeOption(
            icon: Icons.email,
            title: 'Link via Email',
            subtitle: 'Receive a linking code via email',
            onTap: () => _linkViaEmail(),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppConfig.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
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
                  const SizedBox(height: 2),
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
            Icon(
              Icons.chevron_right,
              color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _copyCode() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Code $_deviceLinkCode copied to clipboard'),
        backgroundColor: AppConfig.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _linkViaPhone() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Phone number linking coming soon'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _linkViaEmail() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Email linking coming soon'),
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

// LinkedDevice model (should be in a separate file)
enum DeviceType { mobile, tablet, desktop, web }

class LinkedDevice {
  final String name;
  final DeviceType type;
  final DateTime lastSeen;
  final bool isActive;
  final String? browser;
  final String os;

  LinkedDevice({
    required this.name,
    required this.type,
    required this.lastSeen,
    required this.isActive,
    this.browser,
    required this.os,
  });

  IconData getDeviceIcon() {
    switch (type) {
      case DeviceType.mobile:
        return Icons.smartphone;
      case DeviceType.tablet:
        return Icons.tablet;
      case DeviceType.desktop:
        return Icons.computer;
      case DeviceType.web:
        return Icons.web;
    }
  }

  Color getDeviceColor() {
    switch (type) {
      case DeviceType.mobile:
        return Colors.blue;
      case DeviceType.tablet:
        return Colors.green;
      case DeviceType.desktop:
        return Colors.purple;
      case DeviceType.web:
        return Colors.orange;
    }
  }
}
