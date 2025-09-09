import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';

class LocationSharingScreen extends StatefulWidget {
  final Function(String, String) onLocationSelected;

  const LocationSharingScreen({
    super.key,
    required this.onLocationSelected,
  });

  @override
  State<LocationSharingScreen> createState() => _LocationSharingScreenState();
}

class _LocationSharingScreenState extends State<LocationSharingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _currentLocation = 'Current Location';
  bool _isLoading = false;

  // Mock location data
  final List<Map<String, dynamic>> _recentLocations = [
    {
      'name': 'Home',
      'address': '123 Main St, City, State',
      'lat': 37.7749,
      'lng': -122.4194,
    },
    {
      'name': 'Work',
      'address': '456 Office Blvd, City, State',
      'lat': 37.7849,
      'lng': -122.4094,
    },
    {
      'name': 'Shopping Mall',
      'address': '789 Retail Ave, City, State',
      'lat': 37.7949,
      'lng': -122.4294,
    },
  ];

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
          'Share Location',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(isDark),

          // Map Preview
          _buildMapPreview(isDark),

          // Location Options
          Expanded(
            child: _buildLocationOptions(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for a place...',
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark ? AppConfig.darkCard : AppConfig.lightCard,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          // Implement search functionality
        },
      ),
    );
  }

  Widget _buildMapPreview(bool isDark) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Mock map background
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.map,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Map Preview',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Current location marker
          Positioned(
            top: 80,
            left: 150,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),

          // Send current location button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () => _sendCurrentLocation(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text('Send Current Location'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationOptions(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick Locations
          Text(
            'Quick Locations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppConfig.darkText : AppConfig.lightText,
            ),
          ),
          const SizedBox(height: 12),

          // Current Location
          _buildLocationTile(
            icon: Icons.my_location,
            title: 'Current Location',
            subtitle: _currentLocation,
            onTap: () => _sendCurrentLocation(),
            isDark: isDark,
          ),

          const SizedBox(height: 24),

          // Recent Locations
          Text(
            'Recent Locations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppConfig.darkText : AppConfig.lightText,
            ),
          ),
          const SizedBox(height: 12),

          ..._recentLocations.map((location) => _buildLocationTile(
            icon: Icons.history,
            title: location['name'],
            subtitle: location['address'],
            onTap: () => _sendLocation(location),
            isDark: isDark,
          )),

          const SizedBox(height: 24),

          // Saved Places
          Text(
            'Saved Places',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? AppConfig.darkText : AppConfig.lightText,
            ),
          ),
          const SizedBox(height: 12),

          _buildLocationTile(
            icon: Icons.add,
            title: 'Add a place',
            subtitle: 'Save your favorite locations',
            onTap: () => _addNewPlace(),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConfig.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppConfig.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  void _sendCurrentLocation() {
    setState(() {
      _isLoading = true;
    });

    // Simulate getting current location
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        widget.onLocationSelected(
          '📍 Current Location',
          'Shared current location',
        );

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Location shared successfully'),
            backgroundColor: AppConfig.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    });
  }

  void _sendLocation(Map<String, dynamic> location) {
    widget.onLocationSelected(
      '📍 ${location['name']}',
      location['address'],
    );

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Location "${location['name']}" shared successfully'),
        backgroundColor: AppConfig.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _addNewPlace() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Add new place feature coming soon'),
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
