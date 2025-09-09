import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../models/group.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';

class ManageAdminsScreen extends StatefulWidget {
  final Group group;

  const ManageAdminsScreen({
    super.key,
    required this.group,
  });

  @override
  State<ManageAdminsScreen> createState() => _ManageAdminsScreenState();
}

class _ManageAdminsScreenState extends State<ManageAdminsScreen> {
  List<User> _admins = [];
  List<User> _regularMembers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  void _loadMembers() {
    setState(() {
      _admins = List.from(widget.group.admins);
      _regularMembers = widget.group.members
          .where((user) => !_admins.any((admin) => admin.id == user.id))
          .toList();
    });
  }

  void _toggleAdminStatus(User user) {
    setState(() {
      if (_admins.contains(user)) {
        // Remove admin status
        _admins.remove(user);
        _regularMembers.add(user);
      } else {
        // Add admin status
        _regularMembers.remove(user);
        _admins.add(user);
      }
    });
  }

  void _saveChanges() {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Admin settings updated successfully'),
            backgroundColor: AppConfig.successColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        Navigator.of(context).pop();
      }
    });
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
            Icons.arrow_back,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Manage Admins',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saveChanges,
            child: Text(
              'Save',
              style: TextStyle(
                color: AppConfig.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Section
            _buildInfoSection(isDark),

            const SizedBox(height: 24),

            // Current Admins
            _buildAdminsSection(isDark),

            const SizedBox(height: 24),

            // Regular Members
            _buildMembersSection(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppConfig.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.admin_panel_settings,
              color: AppConfig.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Group Admins',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppConfig.darkText : AppConfig.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Admins can manage group settings, add/remove members, and moderate content.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminsSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Current Admins',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_admins.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppConfig.primaryColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppConfig.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          ),
          child: _admins.isEmpty
              ? _buildEmptyState('No admins assigned', isDark)
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _admins.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                  itemBuilder: (context, index) {
                    final admin = _admins[index];
                    final isCreator = admin.id == widget.group.createdBy.id;

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: AppConfig.primaryColor,
                        backgroundImage: admin.profilePicture != null
                            ? NetworkImage(admin.profilePicture!)
                            : null,
                        child: admin.profilePicture == null
                            ? Text(
                                admin.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null,
                      ),
                      title: Row(
                        children: [
                          Text(
                            admin.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppConfig.darkText : AppConfig.lightText,
                            ),
                          ),
                          if (isCreator) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppConfig.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Creator',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppConfig.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppConfig.primaryColor,
                        ),
                      ),
                      trailing: isCreator
                          ? null
                          : IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                              ),
                              onPressed: () => _toggleAdminStatus(admin),
                            ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMembersSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Group Members',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_regularMembers.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppConfig.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          ),
          child: _regularMembers.isEmpty
              ? _buildEmptyState('No regular members', isDark)
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _regularMembers.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                  ),
                  itemBuilder: (context, index) {
                    final member = _regularMembers[index];

                    return ListTile(
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.grey.shade400,
                        backgroundImage: member.profilePicture != null
                            ? NetworkImage(member.profilePicture!)
                            : null,
                        child: member.profilePicture == null
                            ? Text(
                                member.name[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null,
                      ),
                      title: Text(
                        member.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppConfig.darkText : AppConfig.lightText,
                        ),
                      ),
                      subtitle: Text(
                        'Member',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.add_circle,
                          color: AppConfig.primaryColor,
                        ),
                        onPressed: () => _toggleAdminStatus(member),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
