import 'package:flutter/material.dart';

class AppConfig {
  static const String appName = 'ChatWave';
  static const String appVersion = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://api.chatwave.com'; // Replace with your backend URL
  static const String apiBaseUrl = 'https://api.chatwave.com'; // For status repository
  static const String wsUrl = 'wss://api.chatwave.com'; // Replace with your WebSocket URL
  
  // Auth Configuration
  static String get authToken => 'mock_token'; // Replace with actual auth token
  
  // Colors
  static const Color primaryColor = Color(0xFF128C7E); // WhatsApp green
  static const Color secondaryColor = Color(0xFF25D366); // WhatsApp light green
  static const Color accentColor = Color(0xFF34B7F1); // WhatsApp blue
  static const Color errorColor = Color(0xFFE53E3E); // Red for errors
  static const Color successColor = Color(0xFF38A169); // Green for success
  static const Color warningColor = Color(0xFFD69E2E); // Yellow for warnings
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF2D2D2D);
  static const Color darkText = Color(0xFFE0E0E0);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  
  // Light theme colors
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF5F5F5);
  static const Color lightText = Color(0xFF212121);
  static const Color lightTextSecondary = Color(0xFF757575);
  
  // Message bubble colors
  static const Color sentMessageColor = Color(0xFFDCF8C6);
  static const Color receivedMessageColor = Color(0xFFFFFFFF);
  static const Color sentMessageTextColor = Color(0xFF000000);
  static const Color receivedMessageTextColor = Color(0xFF000000);
  
  // Typography
  static const String fontFamily = 'Roboto';
  
  // Dimensions
  static const double borderRadius = 12.0;
  static const double messageBorderRadius = 18.0;
  static const double padding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  
  // Animation durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppConfig.fontFamily,
      colorScheme: const ColorScheme.light(
        primary: AppConfig.primaryColor,
        secondary: AppConfig.secondaryColor,
        surface: AppConfig.lightSurface,
        background: AppConfig.lightBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppConfig.lightText,
        onBackground: AppConfig.lightText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppConfig.lightCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConfig.largePadding,
            vertical: AppConfig.padding,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          borderSide: const BorderSide(color: AppConfig.primaryColor, width: 2),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: AppConfig.fontFamily,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppConfig.primaryColor,
        secondary: AppConfig.secondaryColor,
        surface: AppConfig.darkSurface,
        background: AppConfig.darkBackground,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppConfig.darkText,
        onBackground: AppConfig.darkText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConfig.darkSurface,
        foregroundColor: AppConfig.darkText,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppConfig.darkText,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppConfig.darkCard,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConfig.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppConfig.largePadding,
            vertical: AppConfig.padding,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
          borderSide: const BorderSide(color: AppConfig.primaryColor, width: 2),
        ),
      ),
    );
  }
}
