import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/user.dart';
import '../../models/call.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/standard_app_bar.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StandardAppBar(
        title: 'Contacts',
        showBackButton: true,
        showSearchButton: true,
        showCameraButton: false,
        showMoreOptions: true,
        moreMenuItems: [
          PopupMenuItem<String>(
            value: 'invite',
            child: Row(
              children: [
                Icon(
                  Icons.person_add,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppConfig.darkText
                      : AppConfig.lightText,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Invite Friends',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppConfig.darkText
                        : AppConfig.lightText,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: 'refresh',
            child: Row(
              children: [
                Icon(
                  Icons.refresh,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppConfig.darkText
                      : AppConfig.lightText,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Text(
                  'Refresh Contacts',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppConfig.darkText
                        : AppConfig.lightText,
                  ),
                ),
              ],
            ),
          ),
        ],
        onMenuItemSelected: (value) {
          switch (value) {
            case 'invite':
              _showInviteDialog(context);
              break;
            case 'refresh':
              _refreshContacts(context);
              break;
          }
        },
      ),
      body: _buildContactsList(context),
    );
  }

  Widget _buildContactsList(BuildContext context) {
    // Mock contacts data - in a real app, this would come from the device contacts
    final contacts = [
      {'name': 'John Doe', 'phone': '+1 234 567 8901'},
      {'name': 'Jane Smith', 'phone': '+1 234 567 8902'},
      {'name': 'Mike Johnson', 'phone': '+1 234 567 8903'},
      {'name': 'Sarah Wilson', 'phone': '+1 234 567 8904'},
      {'name': 'David Brown', 'phone': '+1 234 567 8905'},
      {'name': 'Lisa Davis', 'phone': '+1 234 567 8906'},
      {'name': 'Tom Miller', 'phone': '+1 234 567 8907'},
      {'name': 'Emma Garcia', 'phone': '+1 234 567 8908'},
    ];

    return ListView.builder(
      itemCount: contacts.length,
      itemBuilder: (context, index) {
        final contact = contacts[index];
        return _buildContactTile(context, contact);
      },
    );
  }

  Widget _buildContactTile(BuildContext context, Map<String, String> contact) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.transparent,
        child: ClipOval(
          child: Image.asset(
            'assets/images/icons/userPlaceholder.png',
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stack) => CircleAvatar(
              radius: 25,
              backgroundColor: AppConfig.primaryColor,
              child: Text(
                contact['name']!.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        contact['name']!,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        contact['phone']!,
        style: TextStyle(
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              // Navigate to chat with this contact
            },
          ),
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () => _makeCall(context, contact, false),
          ),
        ],
      ),
      onTap: () {
        // Navigate to contact details or start chat
      },
    );
  }


  void _showInviteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Friends'),
        content: const Text('Share ChatWave with your friends!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invitation functionality coming soon!')),
              );
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _refreshContacts(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contacts refreshed successfully!')),
    );
  }

  void _makeCall(BuildContext context, Map<String, String> contact, bool isVideo) {
    // Create a mock User object from contact data
    final receiver = User(
      id: 'contact_${contact['phone']}', // Use phone as unique ID
      name: contact['name']!,
      phoneNumber: contact['phone']!,
      profilePicture: null,
      about: null,
      isOnline: true,
      lastSeen: DateTime.now(),
    );

    // Create a call object for navigation
    final call = Call(
      id: 'call_${DateTime.now().millisecondsSinceEpoch}',
      callerId: MockDataService.currentUser.id,
      receiverId: receiver.id,
      type: isVideo ? CallType.video : CallType.voice,
      status: CallStatus.initial,
      startTime: DateTime.now(),
      isIncoming: false,
    );

    Navigator.pushNamed(context, '/call', arguments: {
      'call': call,
      'receiver': receiver,
      'isVideo': isVideo,
      'isIncoming': false,
    });
  }
}
