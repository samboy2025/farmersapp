import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class AppHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final bool isSearching;
  final VoidCallback? onSearchToggle;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final String? searchHint;
  final bool showSearch;
  final bool showMoreOptions;
  final VoidCallback? onMoreOptions;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBackButton = false,
    this.onBackPressed,
    this.actions,
    this.isSearching = false,
    this.onSearchToggle,
    this.searchController,
    this.onSearchChanged,
    this.searchHint,
    this.showSearch = false,
    this.showMoreOptions = false,
    this.onMoreOptions,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Main Header
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 16,
            vertical: isTablet ? 16 : 12,
          ),
          decoration: BoxDecoration(
            color: backgroundColor ?? 
                  (isDark ? AppConfig.darkSurface : Colors.white),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Back button
              if (showBackButton)
                IconButton(
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                  icon: Icon(
                    Icons.arrow_back,
                    color: foregroundColor ?? 
                           (isDark ? AppConfig.darkText : const Color(0xFF111B21)),
                  ),
                  splashRadius: 20,
                ),
              
              // Title section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.w700,
                        color: foregroundColor ?? 
                               (isDark ? AppConfig.darkText : const Color(0xFF111B21)),
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: foregroundColor?.withOpacity(0.7) ?? 
                                 (isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781)),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              // Action buttons
              Row(
                children: [
                  // Search button
                  if (showSearch)
                    IconButton(
                      onPressed: onSearchToggle,
                      icon: Icon(
                        isSearching ? Icons.close : Icons.search,
                        color: foregroundColor ?? 
                               (isDark ? AppConfig.darkText : const Color(0xFF667781)),
                        size: isTablet ? 24 : 20,
                      ),
                      tooltip: isSearching ? 'Close search' : 'Search',
                      constraints: BoxConstraints(
                        minWidth: isTablet ? 48 : 44,
                        minHeight: isTablet ? 48 : 44,
                      ),
                      splashRadius: isTablet ? 24 : 20,
                    ),
                  
                  // More options button
                  if (showMoreOptions)
                    IconButton(
                      onPressed: onMoreOptions,
                      icon: Icon(
                        Icons.more_vert,
                        color: foregroundColor ?? 
                               (isDark ? AppConfig.darkText : const Color(0xFF667781)),
                        size: isTablet ? 24 : 20,
                      ),
                      tooltip: 'More options',
                      constraints: BoxConstraints(
                        minWidth: isTablet ? 48 : 44,
                        minHeight: isTablet ? 48 : 44,
                      ),
                      splashRadius: isTablet ? 24 : 20,
                    ),
                  
                  // Custom actions
                  if (actions != null) ...actions!,
                ],
              ),
            ],
          ),
        ),
        
        // Search bar (when searching)
        if (isSearching && searchController != null)
          _buildSearchBar(context, isTablet, isDark),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isTablet, bool isDark) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        autofocus: true,
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: searchHint ?? 'Search...',
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
            size: isTablet ? 24 : 20,
          ),
          suffixIcon: searchController!.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    searchController!.clear();
                    if (onSearchChanged != null) onSearchChanged!('');
                  },
                  icon: Icon(
                    Icons.clear,
                    color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                    size: isTablet ? 20 : 18,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
            borderSide: BorderSide(
              color: isDark ? AppConfig.darkTextSecondary : Colors.grey.shade300,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
            borderSide: const BorderSide(color: AppConfig.primaryColor),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isTablet ? 16 : 12,
            vertical: isTablet ? 14 : 12,
          ),
          filled: true,
          fillColor: isDark ? AppConfig.darkCard : Colors.grey.shade50,
        ),
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          color: isDark ? AppConfig.darkText : AppConfig.lightText,
        ),
      ),
    );
  }
}

// Extension for consistent empty states
class AppEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? action;
  final bool isTablet;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.action,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 40 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isTablet ? 80 : 64,
              color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
            ),
            SizedBox(height: isTablet ? 24 : 16),
            Text(
              title,
              style: TextStyle(
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 12 : 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (action != null) ...[
              SizedBox(height: isTablet ? 32 : 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

// Extension for consistent loading states
class AppLoadingState extends StatelessWidget {
  final String message;
  final bool isTablet;

  const AppLoadingState({
    super.key,
    required this.message,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: const AlwaysStoppedAnimation<Color>(AppConfig.primaryColor),
            strokeWidth: 3,
          ),
          SizedBox(height: isTablet ? 24 : 16),
          Text(
            message,
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
