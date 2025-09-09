import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;
  final bool isTablet;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: isTablet ? 60 : 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary
              ? Colors.white
              : AppConfig.primaryColor,
          foregroundColor: isSecondary
              ? AppConfig.primaryColor
              : Colors.white,
          elevation: isSecondary ? 0 : 2,
          shadowColor: AppConfig.primaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSecondary
                ? BorderSide(color: AppConfig.primaryColor, width: 1.5)
                : BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 32 : 24,
            vertical: isTablet ? 18 : 16,
          ),
        ),
        child: isLoading
            ? SizedBox(
                height: isTablet ? 24 : 20,
                width: isTablet ? 24 : 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isSecondary ? AppConfig.primaryColor : Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: isTablet ? 24 : 20,
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class AuthTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isTablet;

  const AuthTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppConfig.primaryColor,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 20 : 16,
          vertical: isTablet ? 16 : 12,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
