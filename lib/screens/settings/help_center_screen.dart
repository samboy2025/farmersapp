import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedCategory = 0;

  final List<Map<String, dynamic>> _categories = [
    {
      'title': 'Getting Started',
      'icon': Icons.play_circle_outline,
      'color': Colors.blue,
      'articles': [
        'How to create an account',
        'Setting up your profile',
        'Adding contacts',
        'Your first message',
      ],
    },
    {
      'title': 'Messages',
      'icon': Icons.message_outlined,
      'color': Colors.green,
      'articles': [
        'Sending messages',
        'Media and attachments',
        'Voice messages',
        'Message reactions',
      ],
    },
    {
      'title': 'Groups',
      'icon': Icons.groups_outlined,
      'color': Colors.purple,
      'articles': [
        'Creating groups',
        'Managing group members',
        'Group settings',
        'Group notifications',
      ],
    },
    {
      'title': 'Calls',
      'icon': Icons.call_outlined,
      'color': Colors.orange,
      'articles': [
        'Making voice calls',
        'Video calling',
        'Call settings',
        'Troubleshooting calls',
      ],
    },
    {
      'title': 'Privacy & Security',
      'icon': Icons.security_outlined,
      'color': Colors.red,
      'articles': [
        'Privacy settings',
        'Blocking contacts',
        'Two-factor authentication',
        'Data and backups',
      ],
    },
    {
      'title': 'Account',
      'icon': Icons.account_circle_outlined,
      'color': Colors.teal,
      'articles': [
        'Account settings',
        'Changing password',
        'Deleting account',
        'Account recovery',
      ],
    },
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'How do I change my profile picture?',
      'answer': 'Go to Settings > Profile > Edit Profile > Tap on the profile picture icon to change it.',
    },
    {
      'question': 'How do I block someone?',
      'answer': 'Open the chat with the person you want to block > Tap on their name > Scroll down and tap "Block".',
    },
    {
      'question': 'How do I delete a message?',
      'answer': 'Long press on the message you want to delete > Tap "Delete" > Choose "Delete for me" or "Delete for everyone".',
    },
    {
      'question': 'How do I create a group?',
      'answer': 'Tap the floating action button > New Group > Select contacts > Set group name and picture.',
    },
    {
      'question': 'How do I backup my chats?',
      'answer': 'Go to Settings > Chats > Chat Backup > Enable backup and set your preferences.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'Help Center',
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

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Actions
                  _buildQuickActions(isDark),

                  const SizedBox(height: 24),

                  // Categories
                  _buildCategories(isDark),

                  const SizedBox(height: 24),

                  // FAQs
                  _buildFAQs(isDark),

                  const SizedBox(height: 24),

                  // Contact Support
                  _buildContactSupport(isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search help articles...',
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: isDark ? AppConfig.darkCard : AppConfig.lightCard,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Help',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildQuickActionCard(
                'Contact Support',
                Icons.support_agent,
                Colors.blue,
                () => _contactSupport(),
                isDark,
              ),
              _buildQuickActionCard(
                'Report Issue',
                Icons.bug_report,
                Colors.red,
                () => _reportIssue(),
                isDark,
              ),
              _buildQuickActionCard(
                'App Info',
                Icons.info,
                Colors.green,
                () => _showAppInfo(),
                isDark,
              ),
              _buildQuickActionCard(
                'Tutorials',
                Icons.play_circle,
                Colors.purple,
                () => _showTutorials(),
                isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDark,
  ) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? AppConfig.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategories(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Browse by Category',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.2,
          ),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final category = _categories[index];
            return _buildCategoryCard(category, isDark);
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> category, bool isDark) {
    return InkWell(
      onTap: () => _openCategory(category),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppConfig.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: category['color'].withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                category['icon'],
                color: category['color'],
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category['title'],
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${category['articles'].length} articles',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQs(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppConfig.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _faqs.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            itemBuilder: (context, index) {
              final faq = _faqs[index];
              return ExpansionTile(
                title: Text(
                  faq['question'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppConfig.darkText : AppConfig.lightText,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      faq['answer'],
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactSupport(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Still Need Help?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppConfig.darkSurface : Colors.white,
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(
                Icons.support_agent,
                size: 48,
                color: AppConfig.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Contact our support team',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Get help from our experts or browse our community forum for answers.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _contactSupport(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Contact Support'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _visitForum(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppConfig.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Community Forum',
                        style: TextStyle(color: AppConfig.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openCategory(Map<String, dynamic> category) {
    // Navigate to category articles
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${category['title']} articles coming soon'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _contactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening support chat...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _reportIssue() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening issue reporter...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showAppInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Showing app information...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showTutorials() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening tutorials...'),
        backgroundColor: AppConfig.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _visitForum() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening community forum...'),
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
