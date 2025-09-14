import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../models/call.dart';
import '../../services/mock_data_service.dart';
import 'contact_qr_screen.dart';
import '../search/search_screen.dart';

class ContactDetailScreen extends StatelessWidget {
  final User contact;

  const ContactDetailScreen({
    super.key,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Info'),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditOptions(context),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showMoreOptions(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            _buildProfileHeader(context),
            
            // Quick actions
            _buildQuickActions(context),
            
            // Contact information
            _buildContactInfo(context),
            
            // Media, links, and docs
            _buildMediaSection(context),
            
            // Additional options
            _buildAdditionalOptions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppConfig.primaryColor,
            AppConfig.primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // Profile picture
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.white,
            backgroundImage: contact.profilePicture != null
                ? NetworkImage(contact.profilePicture!)
                : null,
            child: contact.profilePicture == null
                ? Text(
                    contact.name.substring(0, 1).toUpperCase(),
                    style: TextStyle(
                      color: AppConfig.primaryColor,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          
          const SizedBox(height: 16),
          
          // Name
          Text(
            contact.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // About
          if (contact.about != null && contact.about!.isNotEmpty)
            Text(
              contact.about!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          
          const SizedBox(height: 16),
          
          // Online status
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: contact.isOnline ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                contact.isOnline ? 'Online' : 'Last seen ${_formatLastSeen(contact.lastSeen)}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            context,
            icon: Icons.message,
            label: 'Message',
            color: AppConfig.primaryColor,
            onTap: () => _startChat(context),
          ),
          _buildActionButton(
            context,
            icon: Icons.call,
            label: 'Call',
            color: AppConfig.successColor,
            onTap: () => _makeCall(context, false),
          ),
          _buildActionButton(
            context,
            icon: Icons.videocam,
            label: 'Video',
            color: AppConfig.accentColor,
            onTap: () => _makeCall(context, true),
          ),
          _buildActionButton(
            context,
            icon: Icons.search,
            label: 'Search',
            color: Colors.orange,
            onTap: () => _searchInChat(context),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoTile(
            icon: Icons.phone,
            title: 'Phone',
            subtitle: contact.phoneNumber,
            onTap: () => _copyToClipboard(context, contact.phoneNumber),
          ),
          _buildInfoTile(
            icon: Icons.info,
            title: 'About',
            subtitle: contact.about ?? 'No status',
            onTap: null,
          ),
          if (contact.isVerified)
            _buildInfoTile(
              icon: Icons.verified,
              title: 'Verified',
              subtitle: 'This contact is verified',
              onTap: null,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
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
      subtitle: Text(subtitle),
      trailing: onTap != null
          ? const Icon(Icons.copy, size: 20)
          : null,
      onTap: onTap,
    );
  }

  Widget _buildMediaSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library, color: AppConfig.primaryColor),
            title: const Text('Media, links, and docs'),
            subtitle: const Text('0 shared'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showMedia(context),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalOptions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: const Text('Block'),
            onTap: () => _blockContact(context),
          ),
          ListTile(
            leading: const Icon(Icons.report, color: Colors.orange),
            title: const Text('Report'),
            onTap: () => _reportContact(context),
          ),
        ],
      ),
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final diff = now.difference(lastSeen);
    
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }

  void _startChat(BuildContext context) {
    // Navigate to chat screen
    Navigator.pop(context);
    // In a real app, this would navigate to the chat
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Opening chat...')),
    );
  }

  void _makeCall(BuildContext context, bool isVideo) {
    // Navigate to call screen
    Navigator.pop(context);

    // Create a call object for navigation
    final call = Call(
      id: 'call_${DateTime.now().millisecondsSinceEpoch}',
      callerId: MockDataService.currentUser.id,
      receiverId: contact.id,
      type: isVideo ? CallType.video : CallType.voice,
      status: CallStatus.initial,
      startTime: DateTime.now(),
      isIncoming: false,
    );

    Navigator.pushNamed(context, '/call', arguments: {
      'call': call,
      'receiver': contact,
      'isVideo': isVideo,
      'isIncoming': false,
    });
  }

  void _searchInChat(BuildContext context) {
    // Navigate to search screen for this contact's messages
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchScreen(
          searchType: 'messages',
          initialQuery: contact.name,
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    // Copy to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard!')),
    );
  }

  void _showMedia(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Media, Links, and Docs'),
        content: const Text('No shared media yet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showEditOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Contact',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Name'),
              onTap: () {
                Navigator.pop(context);
                _editContactName(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Edit Phone Number'),
              onTap: () {
                Navigator.pop(context);
                _editPhoneNumber(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Contact'),
              onTap: () {
                Navigator.pop(context);
                _shareContact(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text('QR Code'),
              onTap: () {
                Navigator.pop(context);
                _showQRCode(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete Contact', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteContact(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editContactName(BuildContext context) {
    final nameController = TextEditingController(text: contact.name);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Name',
            hintText: 'Enter contact name',
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
              // Update contact name
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Name updated!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editPhoneNumber(BuildContext context) {
    final phoneController = TextEditingController(text: contact.phoneNumber);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Phone Number'),
        content: TextField(
          controller: phoneController,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Enter phone number',
          ),
          keyboardType: TextInputType.phone,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update phone number
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Phone number updated!')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _shareContact(BuildContext context) {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing contact...')),
    );
  }

  void _showQRCode(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactQrScreen(contact: contact),
      ),
    );
  }

  void _blockContact(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block Contact'),
        content: Text('Are you sure you want to block ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact blocked!')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _reportContact(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Contact'),
        content: const Text('Report functionality coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _deleteContact(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Are you sure you want to delete ${contact.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Contact deleted!')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
