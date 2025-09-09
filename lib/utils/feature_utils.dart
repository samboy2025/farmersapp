import 'package:flutter/material.dart';
import '../config/app_config.dart';

class FeatureUtils {
  /// Shows a consistent "feature in development" message
  static void showFeatureInDevelopment(
    BuildContext context,
    String featureName, {
    String? description,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isTablet = MediaQuery.of(context).size.width > 600;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppConfig.darkSurface : Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(isTablet ? 24 : 20),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: isTablet ? 50 : 40,
                height: 4,
                margin: EdgeInsets.only(bottom: isTablet ? 24 : 16),
                decoration: BoxDecoration(
                  color: isDark ? AppConfig.darkTextSecondary : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Feature icon
              Container(
                width: isTablet ? 80 : 64,
                height: isTablet ? 80 : 64,
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? Icons.construction,
                  size: isTablet ? 40 : 32,
                  color: AppConfig.primaryColor,
                ),
              ),
              
              SizedBox(height: isTablet ? 24 : 16),
              
              // Feature name
              Text(
                '$featureName In Development',
                style: TextStyle(
                  fontSize: isTablet ? 22 : 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppConfig.darkText : AppConfig.lightText,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: isTablet ? 16 : 12),
              
              // Description
              Text(
                description ?? 'This feature is currently being developed and will be available in a future update.',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: isTablet ? 32 : 24),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppConfig.primaryColor),
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 16 : 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                        ),
                      ),
                      child: Text(
                        'Got it',
                        style: TextStyle(
                          color: AppConfig.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: isTablet ? 16 : 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        showRequestFeatureDialog(context, featureName);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConfig.primaryColor,
                        padding: EdgeInsets.symmetric(
                          vertical: isTablet ? 16 : 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(isTablet ? 12 : 10),
                        ),
                      ),
                      child: Text(
                        'Request Feature',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: isTablet ? 16 : 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Shows a feature request dialog
  static void showRequestFeatureDialog(BuildContext context, String featureName) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppConfig.darkSurface : Colors.white,
        title: Text(
          'Request $featureName',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Thank you for your interest! We\'ll prioritize $featureName based on user demand.',
          style: TextStyle(
            color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$featureName request submitted!'),
                  backgroundColor: AppConfig.successColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConfig.primaryColor,
            ),
            child: const Text(
              'Submit',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows a quick success message
  static void showFeatureSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConfig.successColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows a quick info message
  static void showFeatureInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConfig.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Shows a quick error message
  static void showFeatureError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConfig.errorColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
