import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import 'link_new_device_screen.dart';

class LinkedDevicesScreen extends StatefulWidget {
  const LinkedDevicesScreen({super.key});

  @override
  State<LinkedDevicesScreen> createState() => _LinkedDevicesScreenState();
}

class _LinkedDevicesScreenState extends State<LinkedDevicesScreen>
    with TickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<LinkedDevice> _devices = [
    LinkedDevice(
      name: 'ChatWave Web',
      type: DeviceType.web,
      lastSeen: DateTime.now().subtract(const Duration(minutes: 5)),
      isActive: true,
      browser: 'Chrome',
      os: 'Windows 11',
    ),
    LinkedDevice(
      name: 'ChatWave Desktop',
      type: DeviceType.desktop,
      lastSeen: DateTime.now().subtract(const Duration(hours: 2)),
      isActive: false,
      browser: null,
      os: 'macOS',
    ),
    LinkedDevice(
      name: 'iPad Pro',
      type: DeviceType.tablet,
      lastSeen: DateTime.now().subtract(const Duration(days: 1)),
      isActive: false,
      browser: null,
      os: 'iPadOS 17',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      backgroundColor: AppConfig.lightBackground,
      appBar: _buildAppBar(context, isTablet),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _isLoading ? _buildLoadingState(isTablet) : _buildDevicesList(isTablet),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isTablet) {
    return AppBar(
      backgroundColor: AppConfig.primaryColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        splashRadius: 20,
      ),
      title: const Text(
        'Linked devices',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: _refreshDevices,
          icon: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.refresh, color: Colors.white),
          tooltip: 'Refresh',
          splashRadius: 20,
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value),
          icon: const Icon(Icons.more_vert, color: Colors.white),
          tooltip: 'More options',
          color: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          itemBuilder: (context) => [
            _buildMenuItem('link_device', 'Link a device', Icons.add_link),
            _buildMenuItem('logout_all', 'Log out from all devices', Icons.logout),
          ],
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(String value, String text, IconData icon) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF667781)),
          const SizedBox(width: 12),
          Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              color: Color(0xFF111B21),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState(bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppConfig.primaryColor),
            strokeWidth: 3,
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'Updating device list...',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: AppConfig.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesList(bool isTablet) {
    return Column(
      children: [
        // Current device banner
        _buildCurrentDeviceBanner(isTablet),
        
        // Linked devices
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 16,
              vertical: isTablet ? 16 : 8,
            ),
            children: [
              // Info section
              _buildInfoSection(isTablet),
              
              SizedBox(height: isTablet ? 32 : 24),
              
              // Devices list
              if (_devices.isNotEmpty) ...[
                _buildSectionHeader('Linked devices', isTablet),
                SizedBox(height: isTablet ? 16 : 12),
                ..._devices.map((device) => _buildDeviceTile(device, isTablet)),
              ] else
                _buildEmptyState(isTablet),
              
              SizedBox(height: isTablet ? 32 : 24),
              
              // Link new device button
              _buildLinkDeviceButton(isTablet),
              
              SizedBox(height: isTablet ? 100 : 80),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentDeviceBanner(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: isTablet ? 20 : 16,
      ),
      decoration: BoxDecoration(
        color: AppConfig.primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: AppConfig.primaryColor.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 12 : 10),
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isTablet ? 14 : 12),
            ),
            child: Icon(
              Icons.smartphone,
              color: AppConfig.primaryColor,
              size: isTablet ? 28 : 24,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'This device',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: AppConfig.primaryColor,
                      ),
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 10 : 8,
                        vertical: isTablet ? 4 : 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppConfig.successColor,
                        borderRadius: BorderRadius.circular(isTablet ? 10 : 8),
                      ),
                      child: Text(
                        'ACTIVE',
                        style: TextStyle(
                          fontSize: isTablet ? 12 : 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Text(
                  'iPhone 15 Pro • iOS 17.1',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: AppConfig.primaryColor.withOpacity(0.8),
                  ),
                ),
                Text(
                  'Last seen: now',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: AppConfig.primaryColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: isTablet ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.devices,
            color: AppConfig.primaryColor,
            size: isTablet ? 48 : 40,
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            'Use ChatWave on other devices',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w600,
              color: AppConfig.lightText,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Link your account to use ChatWave on computers, tablets, and other phones. All your messages will be synced.',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: AppConfig.lightTextSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isTablet) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 4 : 0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.w600,
          color: AppConfig.lightText,
        ),
      ),
    );
  }

  Widget _buildDeviceTile(LinkedDevice device, bool isTablet) {
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 12 : 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: isTablet ? 8 : 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 12 : 8,
        ),
        leading: Container(
          padding: EdgeInsets.all(isTablet ? 12 : 10),
          decoration: BoxDecoration(
            color: _getDeviceColor(device.type).withOpacity(0.1),
            borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
          ),
          child: Icon(
            _getDeviceIcon(device.type),
            color: _getDeviceColor(device.type),
            size: isTablet ? 24 : 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                device.name,
                style: TextStyle(
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppConfig.lightText,
                ),
              ),
            ),
            if (device.isActive)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 8 : 6,
                  vertical: isTablet ? 4 : 2,
                ),
                decoration: BoxDecoration(
                  color: AppConfig.successColor,
                  borderRadius: BorderRadius.circular(isTablet ? 8 : 6),
                ),
                child: Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontSize: isTablet ? 10 : 8,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: isTablet ? 6 : 4),
            if (device.browser != null)
              Text(
                '${device.browser} • ${device.os}',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: AppConfig.lightTextSecondary,
                ),
              )
            else
              Text(
                device.os,
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: AppConfig.lightTextSecondary,
                ),
              ),
            SizedBox(height: isTablet ? 4 : 2),
            Text(
              'Last seen: ${_formatLastSeen(device.lastSeen)}',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                color: AppConfig.lightTextSecondary,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleDeviceAction(value, device),
          icon: Icon(
            Icons.more_vert,
            color: AppConfig.lightTextSecondary,
            size: isTablet ? 20 : 18,
          ),
          tooltip: 'Device options',
          itemBuilder: (context) => [
            _buildMenuItem('logout', 'Log out', Icons.logout),
            _buildMenuItem('delete', 'Remove device', Icons.delete),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 40 : 32),
      child: Column(
        children: [
          Icon(
            Icons.devices_other,
            size: isTablet ? 80 : 64,
            color: AppConfig.lightTextSecondary,
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            'No linked devices',
            style: TextStyle(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w600,
              color: AppConfig.lightText,
            ),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            'Link a device to use ChatWave on computers and tablets',
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: AppConfig.lightTextSecondary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLinkDeviceButton(bool isTablet) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: isTablet ? 8 : 4),
      child: ElevatedButton.icon(
        onPressed: _showLinkDeviceBottomSheet,
        icon: const Icon(Icons.add_link, color: Colors.white),
        label: const Text(
          'Link a device',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.primaryColor,
          padding: EdgeInsets.symmetric(
            vertical: isTablet ? 16 : 14,
            horizontal: isTablet ? 24 : 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  IconData _getDeviceIcon(DeviceType type) {
    switch (type) {
      case DeviceType.web:
        return Icons.web;
      case DeviceType.desktop:
        return Icons.computer;
      case DeviceType.tablet:
        return Icons.tablet;
      case DeviceType.mobile:
        return Icons.smartphone;
    }
  }

  Color _getDeviceColor(DeviceType type) {
    switch (type) {
      case DeviceType.web:
        return Colors.blue;
      case DeviceType.desktop:
        return Colors.purple;
      case DeviceType.tablet:
        return Colors.orange;
      case DeviceType.mobile:
        return AppConfig.primaryColor;
    }
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _refreshDevices() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate refresh
    await Future.delayed(const Duration(milliseconds: 1500));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Device list updated'),
          backgroundColor: AppConfig.successColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'link_device':
        _showLinkDeviceBottomSheet();
        break;
      case 'logout_all':
        _showLogoutAllDialog();
        break;
    }
  }

  void _handleDeviceAction(String action, LinkedDevice device) {
    switch (action) {
      case 'logout':
        _showLogoutDeviceDialog(device);
        break;
      case 'delete':
        _showDeleteDeviceDialog(device);
        break;
    }
  }

  void _showLinkDeviceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildLinkDeviceBottomSheet(),
    );
  }

  Widget _buildLinkDeviceBottomSheet() {
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isTablet ? 24 : 20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: isTablet ? 50 : 40,
            height: 4,
            margin: EdgeInsets.only(top: isTablet ? 16 : 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: EdgeInsets.all(isTablet ? 24 : 20),
            child: Column(
              children: [
                Icon(
                  Icons.qr_code,
                  size: isTablet ? 80 : 64,
                  color: AppConfig.primaryColor,
                ),
                SizedBox(height: isTablet ? 20 : 16),
                Text(
                  'Link a device',
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 20,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.lightText,
                  ),
                ),
                SizedBox(height: isTablet ? 12 : 8),
                Text(
                  'Open ChatWave Web or Desktop and scan the QR code',
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: AppConfig.lightTextSecondary,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: isTablet ? 24 : 20),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LinkNewDeviceScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: isTablet ? 16 : 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                      ),
                    ),
                    child: const Text(
                      'Scan QR code',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                
                SizedBox(height: isTablet ? 16 : 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out from all devices?'),
        content: const Text(
          'You will be logged out from all linked devices. You can link them again later.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showFeatureComingSoon('Logout All Devices');
            },
            child: Text(
              'Log out',
              style: TextStyle(color: AppConfig.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDeviceDialog(LinkedDevice device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Log out from ${device.name}?'),
        content: const Text(
          'This device will be logged out and you will need to link it again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showFeatureComingSoon('Logout Device');
            },
            child: Text(
              'Log out',
              style: TextStyle(color: AppConfig.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDeviceDialog(LinkedDevice device) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${device.name}?'),
        content: const Text(
          'This device will be permanently removed from your account.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showFeatureComingSoon('Remove Device');
            },
            child: Text(
              'Remove',
              style: TextStyle(color: AppConfig.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showFeatureComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature feature coming soon!'),
        backgroundColor: AppConfig.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

enum DeviceType { web, desktop, tablet, mobile }

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
}
