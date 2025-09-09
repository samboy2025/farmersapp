import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/group.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';
import 'edit_group_info_screen.dart';
import 'add_members_screen.dart';
import 'manage_admins_screen.dart';
import 'group_qr_screen.dart';

class GroupInfoScreen extends StatefulWidget {
  final Group group;

  const GroupInfoScreen({
    super.key,
    required this.group,
  });

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUser = MockDataService.currentUser;
    final isAdmin = widget.group.admins.any((admin) => admin.id == currentUser.id);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Info'),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _editGroupInfo(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Group header
            _buildGroupHeader(),
            
            // Group actions
            _buildGroupActions(),
            
            // Group description
            if (widget.group.description != null && widget.group.description!.isNotEmpty)
              _buildGroupDescription(),
            
            // Members section
            _buildMembersSection(),
            
            // Group settings
            _buildGroupSettings(),
            
            // Admin actions
            if (isAdmin) _buildAdminActions(),
            
            // Leave/Delete group
            _buildGroupActionsBottom(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Group avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppConfig.primaryColor,
              borderRadius: BorderRadius.circular(50),
            ),
            child: widget.group.groupPicture != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.network(
                      widget.group.groupPicture!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(
                    Icons.groups,
                    color: Colors.white,
                    size: 50,
                  ),
          ),
          
          const SizedBox(height: 16),
          
          // Group name
          Text(
            widget.group.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 8),
          
          // Member count
          Text(
            '${widget.group.members.length} members',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Created info
          Text(
            'Created by ${widget.group.createdBy.name}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.share,
              label: 'Share',
              onTap: () => _shareGroup(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              icon: Icons.qr_code,
              label: 'QR Code',
              onTap: () => _showQRCode(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              icon: Icons.person_add,
              label: 'Invite',
              onTap: () => _inviteMembers(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppConfig.primaryColor,
              size: 24,
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

  Widget _buildGroupDescription() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.group.description!,
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Members (${widget.group.members.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => _viewAllMembers(),
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Members grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: widget.group.members.length > 8 ? 8 : widget.group.members.length,
            itemBuilder: (context, index) {
              final member = widget.group.members[index];
              final isAdmin = widget.group.admins.any((admin) => admin.id == member.id);
              
              return Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.transparent,
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/icons/userPlaceholder.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => CircleAvatar(
                              radius: 30,
                              backgroundColor: AppConfig.primaryColor,
                              child: Text(
                                member.name.substring(0, 1).toUpperCase(),
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
                      if (isAdmin)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppConfig.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    member.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
          
          if (widget.group.members.length > 8)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: Text(
                  'and ${widget.group.members.length - 8} more',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGroupSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildSettingTile(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'All messages',
            onTap: () => _changeNotificationSettings(),
          ),
          _buildSettingTile(
            icon: Icons.wallpaper,
            title: 'Chat Wallpaper',
            subtitle: 'Default',
            onTap: () => _changeWallpaper(),
          ),
          _buildSettingTile(
            icon: Icons.search,
            title: 'Search Messages',
            subtitle: 'Search in ${widget.group.name}',
            onTap: () => _searchMessages(),
          ),
          _buildSettingTile(
            icon: Icons.media_bluetooth_on,
            title: 'Media, Links, and Docs',
            subtitle: 'View shared media',
            onTap: () => _viewMedia(),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppConfig.primaryColor,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildAdminActions() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin Actions',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          _buildAdminActionButton(
            icon: Icons.person_add,
            label: 'Add Members',
            onTap: () => _addMembers(),
          ),
          _buildAdminActionButton(
            icon: Icons.admin_panel_settings,
            label: 'Manage Admins',
            onTap: () => _manageAdmins(),
          ),
          _buildAdminActionButton(
            icon: Icons.settings,
            label: 'Group Settings',
            onTap: () => _groupSettings(),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color: AppConfig.primaryColor,
        ),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildGroupActionsBottom() {
    final currentUser = MockDataService.currentUser;
    final isAdmin = widget.group.admins.any((admin) => admin.id == currentUser.id);
    final isCreator = widget.group.createdBy.id == currentUser.id;
    
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          if (!isCreator)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => _leaveGroup(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Leave Group'),
              ),
            ),
          
          if (isCreator)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _deleteGroup(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Delete Group'),
              ),
            ),
        ],
      ),
    );
  }

  // Action methods
  void _editGroupInfo() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditGroupInfoScreen(group: widget.group),
      ),
    ).then((_) {
      // Refresh group info if needed
      setState(() {});
    });
  }

  void _shareGroup() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Sharing group link...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showQRCode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupQrScreen(group: widget.group),
      ),
    );
  }

  void _inviteMembers() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening contacts to invite...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _viewAllMembers() {
    // This could open a detailed members list screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening members list...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _changeNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening notification settings...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _changeWallpaper() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening wallpaper settings...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _searchMessages() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening message search...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _viewMedia() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening media gallery...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _addMembers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMembersScreen(group: widget.group),
      ),
    );
  }

  void _manageAdmins() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageAdminsScreen(group: widget.group),
      ),
    );
  }

  void _groupSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening group settings...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _leaveGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Group'),
        content: Text('Are you sure you want to leave "${widget.group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Left ${widget.group.name}')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _deleteGroup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Group'),
        content: Text('Are you sure you want to delete "${widget.group.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted ${widget.group.name}')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
