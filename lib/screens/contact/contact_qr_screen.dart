import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';

class ContactQrScreen extends StatefulWidget {
  final User contact;

  const ContactQrScreen({
    super.key,
    required this.contact,
  });

  @override
  State<ContactQrScreen> createState() => _ContactQrScreenState();
}

class _ContactQrScreenState extends State<ContactQrScreen> {
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
          '${widget.contact.name}\'s QR Code',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareQR(),
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _downloadQR(),
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // QR Code Card
            _buildQRCard(isDark),

            const SizedBox(height: 24),

            // Contact Info
            _buildContactInfo(isDark),

            const SizedBox(height: 24),

            // Instructions
            _buildInstructions(isDark),

            const SizedBox(height: 24),

            // Actions
            _buildActions(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
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
          // QR Code
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: QrImageView(
              data: 'chatwave://contact/${widget.contact.id}',
              version: QrVersions.auto,
              size: 200,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
          ),

          const SizedBox(height: 16),

          // Contact Name
          Text(
            widget.contact.name,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? AppConfig.darkText : AppConfig.lightText,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Contact Number
          Text(
            widget.contact.phoneNumber,
            style: TextStyle(
              fontSize: 16,
              color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(bool isDark) {
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
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppConfig.darkText : AppConfig.lightText,
            ),
          ),
          const SizedBox(height: 16),

          // Phone Number
          _buildInfoRow(
            icon: Icons.phone,
            label: 'Phone',
            value: widget.contact.phoneNumber,
            isDark: isDark,
          ),

          const SizedBox(height: 12),

          // Email (if available)
          if (widget.contact.email != null && widget.contact.email!.isNotEmpty) ...[
            _buildInfoRow(
              icon: Icons.email,
              label: 'Email',
              value: widget.contact.email!,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
          ],

          // Status
          _buildInfoRow(
            icon: Icons.circle,
            label: 'Status',
            value: widget.contact.isOnline ? 'Online' : 'Last seen recently',
            isDark: isDark,
            iconColor: widget.contact.isOnline ? Colors.green : Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConfig.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppConfig.primaryColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
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
                'How to add this contact',
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
            'Open ChatWave on another device',
            isDark,
          ),
          _buildInstructionStep(
            '2',
            'Tap the QR scanner in the app',
            isDark,
          ),
          _buildInstructionStep(
            '3',
            'Scan this QR code',
            isDark,
          ),
          _buildInstructionStep(
            '4',
            'Contact will be added automatically',
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

  Widget _buildActions(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: Column(
        children: [
          Text(
            'Share this QR code',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppConfig.darkText : AppConfig.lightText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.share,
                  label: 'Share',
                  color: AppConfig.primaryColor,
                  onTap: () => _shareQR(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.download,
                  label: 'Download',
                  color: Colors.green,
                  onTap: () => _downloadQR(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  icon: Icons.copy,
                  label: 'Copy Link',
                  color: Colors.blue,
                  onTap: () => _copyLink(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  icon: Icons.refresh,
                  label: 'Regenerate',
                  color: Colors.orange,
                  onTap: () => _regenerateQR(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _shareQR() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sharing QR code...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _downloadQR() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Downloading QR code...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _copyLink() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Contact link copied to clipboard'),
        backgroundColor: AppConfig.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _regenerateQR() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('QR code regenerated'),
        backgroundColor: AppConfig.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
