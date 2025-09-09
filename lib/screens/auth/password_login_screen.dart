import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_config.dart';
import '../../widgets/auth/auth_input_field.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/auth_header.dart';
import 'otp_login_screen.dart';
import 'forgot_password_screen.dart';

class PasswordLoginScreen extends StatefulWidget {
  const PasswordLoginScreen({super.key});

  @override
  State<PasswordLoginScreen> createState() => _PasswordLoginScreenState();
}

class _PasswordLoginScreenState extends State<PasswordLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '08012345678');
  final _passwordController = TextEditingController(text: 'demo123');
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _loginWithPassword() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate login process
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isLoading = false;
        });

        // For demo purposes, accept any password
        Navigator.pushReplacementNamed(context, '/home');
      });
    }
  }

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
                      title: 'Login with Password',
                      subtitle: 'Enter your phone number and password',
                      isTablet: isTablet,
                    ),

                    SizedBox(height: isTablet ? 48 : 40),

                    // Login Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Phone Number Input
                          AuthInputField(
                            label: 'Phone Number',
                            hint: '08012345678',
                            controller: _phoneController,
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            isTablet: isTablet,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your phone number';
                              }
                              if (value.trim().length < 11) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: isTablet ? 16 : 12),

                          // Password Input
                          AuthInputField(
                            label: 'Password',
                            hint: 'Enter your password',
                            controller: _passwordController,
                            prefixIcon: Icons.lock_outline,
                            obscureText: true,
                            isTablet: isTablet,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isTablet ? 16 : 12),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgotPasswordScreen(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: AppConfig.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isTablet ? 32 : 24),

                    // Login Button
                    AuthButton(
                      text: 'Sign In',
                      onPressed: _isLoading ? null : _loginWithPassword,
                      isLoading: _isLoading,
                      isTablet: isTablet,
                      icon: Icons.login,
                    ),

                    SizedBox(height: isTablet ? 32 : 24),

                    // Login Method Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Want to use OTP? ',
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const OtpLoginScreen(),
                            ),
                          ),
                          child: Text(
                            'Login with OTP',
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
}
