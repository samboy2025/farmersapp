import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/auth_header.dart';
import 'otp_login_screen.dart';
import 'password_login_screen.dart';
import 'registration_screen.dart';

enum LoginMethod { otp, password }

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.darkBackground : AppConfig.lightBackground,
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(isTablet ? 32 : 24),
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: isTablet ? 500 : double.infinity,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header
                      AuthHeader(
                        title: 'Welcome Back',
                      subtitle: 'Choose your login method',
                        isTablet: isTablet,
                      ),
                      
                      SizedBox(height: isTablet ? 48 : 40),
                      
                    // Login Method Options
                    _buildLoginMethodOptions(context, isTablet, isDark),
                      
                      SizedBox(height: isTablet ? 32 : 24),
                      
                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account? ',
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegistrationScreen(),
                              ),
                            ),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                fontSize: isTablet ? 16 : 14,
                                color: AppConfig.primaryColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      SizedBox(height: isTablet ? 24 : 16),
                      
                      // Terms
                      Text(
                        'By continuing, you agree to our Terms of Service and Privacy Policy',
                        style: TextStyle(
                          fontSize: isTablet ? 14 : 12,
                          color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginMethodOptions(BuildContext context, bool isTablet, bool isDark) {
    return Column(
      children: [
        // OTP Login Option
        _buildLoginMethodCard(
          context: context,
          title: 'Login with OTP',
          subtitle: 'Receive a verification code via SMS',
          icon: Icons.sms,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OtpLoginScreen(),
            ),
          ),
          isTablet: isTablet,
          isDark: isDark,
        ),

        SizedBox(height: isTablet ? 20 : 16),

        // Password Login Option
        _buildLoginMethodCard(
          context: context,
          title: 'Login with Password',
          subtitle: 'Use your phone number and password',
          icon: Icons.lock,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PasswordLoginScreen(),
            ),
          ),
          isTablet: isTablet,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildLoginMethodCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isTablet,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 24 : 20),
            decoration: BoxDecoration(
          color: isDark ? AppConfig.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade200,
                width: 1,
              ),
            ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 16 : 14),
              decoration: BoxDecoration(
                color: AppConfig.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: isTablet ? 32 : 28,
                color: AppConfig.primaryColor,
              ),
            ),
            SizedBox(width: isTablet ? 20 : 16),
            Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Text(
                    title,
                      style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppConfig.darkText : AppConfig.lightText,
                      ),
                    ),
                  SizedBox(height: isTablet ? 4 : 2),
                Text(
                    subtitle,
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
            Icon(
              Icons.arrow_forward_ios,
              size: isTablet ? 20 : 18,
                color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
