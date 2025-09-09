import 'package:flutter/material.dart';
import '../../config/app_config.dart';
import '../../widgets/auth/auth_input_field.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/auth_header.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetEmail() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _emailSent = true;
          });
        }
      });
    }
  }

  void _resendEmail() {
    setState(() {
      _emailSent = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
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
          'Forgot Password',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isTablet ? 500 : double.infinity,
                ),
                child: _emailSent ? _buildEmailSentView(isTablet, isDark) : _buildResetForm(isTablet, isDark),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResetForm(bool isTablet, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Header
        AuthHeader(
          title: 'Reset Password',
          subtitle: 'Enter your email address and we\'ll send you a link to reset your password',
          isTablet: isTablet,
        ),

        SizedBox(height: isTablet ? 48 : 40),

        // Reset Form
        Form(
          key: _formKey,
          child: Column(
            children: [
              AuthInputField(
                controller: _emailController,
                label: 'Email Address',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email address';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),

        SizedBox(height: isTablet ? 32 : 24),

        // Send Reset Email Button
        AuthButton(
          text: 'Send Reset Link',
          onPressed: _sendResetEmail,
          isLoading: _isLoading,
          isTablet: isTablet,
        ),

        SizedBox(height: isTablet ? 24 : 16),

        // Back to Login
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Back to Login',
            style: TextStyle(
              color: AppConfig.primaryColor,
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        SizedBox(height: isTablet ? 32 : 24),

        // Help Text
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppConfig.darkCard : AppConfig.lightCard,
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline,
                color: AppConfig.primaryColor,
                size: 24,
              ),
              const SizedBox(height: 8),
              Text(
                'Make sure to check your spam folder if you don\'t see the reset email in your inbox.',
                style: TextStyle(
                  fontSize: isTablet ? 14 : 12,
                  color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmailSentView(bool isTablet, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Success Icon
        Container(
          width: isTablet ? 120 : 100,
          height: isTablet ? 120 : 100,
          decoration: BoxDecoration(
            color: AppConfig.successColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check_circle,
            color: AppConfig.successColor,
            size: isTablet ? 60 : 50,
          ),
        ),

        SizedBox(height: isTablet ? 32 : 24),

        // Success Title
        Text(
          'Email Sent!',
          style: TextStyle(
            fontSize: isTablet ? 28 : 24,
            fontWeight: FontWeight.w700,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: isTablet ? 16 : 12),

        // Success Message
        Text(
          'We\'ve sent a password reset link to',
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 4),

        Text(
          _emailController.text,
          style: TextStyle(
            fontSize: isTablet ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: AppConfig.primaryColor,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: isTablet ? 32 : 24),

        // Resend Button
        TextButton(
          onPressed: _resendEmail,
          child: Text(
            'Didn\'t receive the email? Resend',
            style: TextStyle(
              color: AppConfig.primaryColor,
              fontSize: isTablet ? 16 : 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        SizedBox(height: isTablet ? 24 : 16),

        // Back to Login Button
        AuthButton(
          text: 'Back to Login',
          onPressed: () => Navigator.of(context).pop(),
          isTablet: isTablet,
        ),

        SizedBox(height: isTablet ? 32 : 24),

        // Help Text
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppConfig.darkCard : AppConfig.lightCard,
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            border: Border.all(
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
          ),
          child: Text(
            'The reset link will expire in 24 hours. Make sure to use it before then.',
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
