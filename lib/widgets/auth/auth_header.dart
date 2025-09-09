import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showLogo;
  final bool isTablet;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showLogo = true,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showLogo) ...[
          Container(
            width: isTablet ? 120 : 100,
            height: isTablet ? 120 : 100,
            decoration: BoxDecoration(
              color: AppConfig.primaryColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppConfig.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.chat_bubble_outline,
              size: isTablet ? 60 : 50,
              color: Colors.white,
            ),
          ),
          SizedBox(height: isTablet ? 40 : 30),
        ],
        Text(
          title,
          style: TextStyle(
            fontSize: isTablet ? 32 : 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111B21),
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: isTablet ? 16 : 12),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
            color: const Color(0xFF667781),
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class AuthAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final bool isTablet;

  const AuthAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onBackPressed,
    this.isTablet = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF111B21),
      elevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: showBackButton ? 0 : 16,
      title: Row(
        children: [
          if (showBackButton) ...[
            IconButton(
              onPressed: onBackPressed ?? () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              color: const Color(0xFF667781),
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
              splashRadius: 20,
            ),
            SizedBox(width: isTablet ? 8 : 4),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 22 : 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111B21),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
