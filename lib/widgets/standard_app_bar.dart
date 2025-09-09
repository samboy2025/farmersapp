import 'package:flutter/material.dart';
import '../config/app_config.dart';
import '../screens/search/search_screen.dart';

class StandardAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final bool showSearchButton;
  final bool showCameraButton;
  final bool showMoreOptions;
  final VoidCallback? onBackPressed;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onCameraPressed;
  final VoidCallback? onMorePressed;
  final List<PopupMenuItem<String>>? moreMenuItems;
  final Function(String)? onMenuItemSelected;

  const StandardAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.showSearchButton = true,
    this.showCameraButton = false,
    this.showMoreOptions = false,
    this.onBackPressed,
    this.onSearchPressed,
    this.onCameraPressed,
    this.onMorePressed,
    this.moreMenuItems,
    this.onMenuItemSelected,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<StandardAppBar> createState() => _StandardAppBarState();
}

class _StandardAppBarState extends State<StandardAppBar> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      backgroundColor: isDark ? AppConfig.darkBackground : AppConfig.lightBackground,
      foregroundColor: isDark ? AppConfig.darkText : AppConfig.lightText,
      elevation: 0,
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      automaticallyImplyLeading: false,
      titleSpacing: widget.showBackButton ? null : 16,
      title: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          widget.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            letterSpacing: 0.5,
          ),
        ),
      ),
      leading: widget.showBackButton
          ? IconButton(
              onPressed: widget.onBackPressed ?? () => Navigator.of(context).pop(),
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
              ),
              tooltip: 'Back',
              splashRadius: 20,
              constraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
            )
          : null,
      actions: [
        // Search button
        if (widget.showSearchButton)
          IconButton(
            onPressed: widget.onSearchPressed ??
                () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SearchScreen(),
                      ),
                    ),
            icon: Icon(
              Icons.search,
              color: isDark ? AppConfig.darkText : AppConfig.lightText,
            ),
            tooltip: 'Search',
            splashRadius: 20,
            constraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
          ),

        // Camera button
        if (widget.showCameraButton)
          IconButton(
            onPressed: widget.onCameraPressed ?? () => _showCameraOptions(context),
            icon: Icon(
              Icons.camera_alt_outlined,
              color: isDark ? AppConfig.darkText : AppConfig.lightText,
            ),
            tooltip: 'Camera',
            splashRadius: 20,
            constraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
          ),

        // More options (three dots)
        if (widget.showMoreOptions && widget.moreMenuItems != null)
          PopupMenuButton<String>(
            onSelected: (value) {
              if (widget.onMenuItemSelected != null) {
                widget.onMenuItemSelected!(value);
              }
            },
            icon: Icon(
              Icons.more_vert,
              color: isDark ? AppConfig.darkText : AppConfig.lightText,
            ),
            tooltip: 'More options',
            color: isDark ? AppConfig.darkSurface : Colors.white,
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            position: PopupMenuPosition.under,
            splashRadius: 20,
            constraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            itemBuilder: (context) => widget.moreMenuItems!,
          ),

        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: isDark
              ? AppConfig.darkTextSecondary.withValues(alpha: 0.1)
              : AppConfig.lightTextSecondary.withValues(alpha: 0.1),
        ),
      ),
    );
  }

  void _showCameraOptions(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppConfig.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
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
              'Camera',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppConfig.primaryColor,
                  size: 20,
                ),
              ),
              title: Text(
                'Take Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                ),
              ),
              subtitle: Text(
                'Capture a new photo',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement camera functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Camera functionality coming soon')),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.photo_library,
                  color: AppConfig.primaryColor,
                  size: 20,
                ),
              ),
              title: Text(
                'Choose from Gallery',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                ),
              ),
              subtitle: Text(
                'Select from your photos',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement gallery functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gallery functionality coming soon')),
                );
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
