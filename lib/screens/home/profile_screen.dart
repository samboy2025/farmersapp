import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/profile/profile_bloc.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../widgets/standard_app_bar.dart';
import '../settings/help_center_screen.dart';
import '../settings/privacy_policy_screen.dart';
import '../devices/linked_devices_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(ProfileFetched());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.darkBackground : AppConfig.lightBackground,
      appBar: StandardAppBar(
        title: 'Profile',
        showBackButton: true,
        showSearchButton: false,
        showCameraButton: false,
        showMoreOptions: true,
        moreMenuItems: [
          PopupMenuItem<String>(
            value: 'qr_code',
            child: Row(
              children: [
                Icon(
                  Icons.qr_code,
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Share Profile',
                  style: TextStyle(
                    color: isDark ? AppConfig.darkText : AppConfig.lightText,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'edit',
            child: Row(
              children: [
                Icon(
                  Icons.edit,
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Edit Profile',
                  style: TextStyle(
                    color: isDark ? AppConfig.darkText : AppConfig.lightText,
                  ),
                ),
              ],
            ),
          ),
        ],
        onMenuItemSelected: (value) {
          switch (value) {
            case 'qr_code':
              _showQRCode(context);
              break;
            case 'edit':
              _showEditProfileDialog(context);
              break;
          }
        },
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: AppConfig.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading profile...',
                    style: TextStyle(
                      color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          } else if (state is ProfileLoadSuccess) {
            return _buildProfileContent(context, state.user);
          } else if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppConfig.darkSurface : AppConfig.lightSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppConfig.errorColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Failed to load profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppConfig.darkText : AppConfig.lightText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      state.message,
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<ProfileBloc>().add(ProfileFetched());
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConfig.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? AppConfig.darkSurface : AppConfig.lightSurface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.person_off,
                      size: 64,
                      color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Profile not available',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppConfig.darkText : AppConfig.lightText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unable to load your profile information',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, User user) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConfig.padding),
      child: Column(
        children: [
          // Profile Picture Section
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => _showChangeProfilePictureDialog(context),
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.transparent,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/icons/userPlaceholder.png',
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => CircleAvatar(
                              radius: 60,
                              backgroundColor: AppConfig.primaryColor,
                              child: Text(
                                user.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppConfig.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (user.about != null && user.about!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    user.about!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Profile Options
          _buildProfileOption(
            context,
            icon: Icons.person,
            title: 'Name',
            subtitle: user.name,
            onTap: () => _showEditNameDialog(context, user),
          ),
          
          _buildProfileOption(
            context,
            icon: Icons.info,
            title: 'About',
            subtitle: user.about ?? 'Add a status',
            onTap: () => _showEditAboutDialog(context, user),
          ),
          
          _buildProfileOption(
            context,
            icon: Icons.phone,
            title: 'Phone',
            subtitle: user.phoneNumber,
            onTap: null, // Phone number cannot be edited
          ),
          
          const Divider(),
          
          // App Settings
          _buildProfileOption(
            context,
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),

          _buildProfileOption(
            context,
            icon: Icons.security,
            title: 'Privacy',
            subtitle: 'Manage privacy settings',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrivacyPolicyScreen(),
                ),
              );
            },
          ),

          _buildProfileOption(
            context,
            icon: Icons.storage,
            title: 'Storage and Data',
            subtitle: 'Manage storage and data usage',
            onTap: () => Navigator.pushNamed(context, '/settings'),
          ),

          _buildProfileOption(
            context,
            icon: Icons.devices,
            title: 'Linked Devices',
            subtitle: 'Manage linked devices',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LinkedDevicesScreen(),
                ),
              );
            },
          ),
          
          const Divider(),
          
          // Help and Support
          _buildProfileOption(
            context,
            icon: Icons.help,
            title: 'Help Center',
            subtitle: 'Get help and support',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpCenterScreen(),
                ),
              );
            },
          ),

          _buildProfileOption(
            context,
            icon: Icons.contact_support,
            title: 'Contact Us',
            subtitle: 'Get in touch with our team',
            onTap: () {
              _showContactDialog(context);
            },
          ),
          
          const Divider(),
          
          // Logout Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showLogoutConfirmation(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConfig.errorColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: AppConfig.padding),
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppConfig.primaryColor,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.grey.shade600,
        ),
      ),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right)
          : null,
      onTap: onTap,
    );
  }

  void _showChangeProfilePictureDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConfig.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                // Implement image picker from gallery
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                // Implement camera functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConfig.padding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Edit Profile',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppConfig.padding),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Edit Name'),
              onTap: () {
                Navigator.pop(context);
                // This will be handled by the edit name dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Edit About'),
              onTap: () {
                Navigator.pop(context);
                // This will be handled by the edit about dialog
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, User user) {
    final nameController = TextEditingController(text: user.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Enter your name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              if (newName.isNotEmpty) {
                context.read<ProfileBloc>().add(
                  ProfileUpdateRequested(name: newName),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showEditAboutDialog(BuildContext context, User user) {
    final aboutController = TextEditingController(text: user.about ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit About'),
        content: TextField(
          controller: aboutController,
          decoration: const InputDecoration(
            labelText: 'About',
            hintText: 'Enter your status',
          ),
          maxLines: 3,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newAbout = aboutController.text.trim();
              context.read<ProfileBloc>().add(
                ProfileUpdateRequested(about: newAbout),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.errorColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showQRCode(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppConfig.darkSurface : AppConfig.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppConfig.darkTextSecondary.withValues(alpha: 0.3) : AppConfig.lightTextSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Share Profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppConfig.darkBackground : AppConfig.lightBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppConfig.darkTextSecondary.withValues(alpha: 0.2) : AppConfig.lightTextSecondary.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'QR Code\nPlaceholder',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Scan this QR code to add me on ChatWave',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement share QR code
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share functionality coming soon')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement download QR code
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Download functionality coming soon')),
                      );
                    },
                    icon: const Icon(Icons.download),
                    label: const Text('Download'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppConfig.darkSurface : AppConfig.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppConfig.darkTextSecondary.withValues(alpha: 0.3) : AppConfig.lightTextSecondary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
              ),
            ),
            const SizedBox(height: 24),
            _buildContactOption(
              context,
              icon: Icons.email,
              title: 'Email Support',
              subtitle: 'support@chatwave.com',
              onTap: () {
                // TODO: Implement email functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email functionality coming soon')),
                );
              },
            ),
            _buildContactOption(
              context,
              icon: Icons.phone,
              title: 'Phone Support',
              subtitle: '+1 (555) 123-4567',
              onTap: () {
                // TODO: Implement phone call functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phone functionality coming soon')),
                );
              },
            ),
            _buildContactOption(
              context,
              icon: Icons.chat,
              title: 'Live Chat',
              subtitle: 'Chat with our support team',
              onTap: () {
                // TODO: Implement live chat functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Live chat functionality coming soon')),
                );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'We typically respond within 24 hours',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactOption(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppConfig.primaryColor.withValues(alpha: 0.1),
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
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
    );
  }
}
