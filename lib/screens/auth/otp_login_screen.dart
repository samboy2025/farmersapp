import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../config/app_config.dart';
import '../../widgets/auth/auth_input_field.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/auth_header.dart';
import 'otp_verification_screen.dart';
import 'password_login_screen.dart';

class OtpLoginScreen extends StatefulWidget {
  const OtpLoginScreen({super.key});

  @override
  State<OtpLoginScreen> createState() => _OtpLoginScreenState();
}

class _OtpLoginScreenState extends State<OtpLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController(text: '08012345678');
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (_formKey.currentState!.validate()) {
      final phoneNumber = _phoneController.text.trim();
      context.read<AuthBloc>().add(AuthLoginRequested(phoneNumber));
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
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpSent) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => OtpVerificationScreen(
                  phoneNumber: state.phoneNumber,
                ),
              ),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppConfig.errorColor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(16),
              ),
            );
          }
        },
        child: SafeArea(
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
                        title: 'Login with OTP',
                        subtitle: 'Enter your phone number to receive OTP',
                        isTablet: isTablet,
                      ),

                      SizedBox(height: isTablet ? 48 : 40),

                      // Phone Number Input
                      Form(
                        key: _formKey,
                        child: AuthInputField(
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
                      ),

                      SizedBox(height: isTablet ? 32 : 24),

                      // Send OTP Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          final isAuthLoading = state is AuthLoading;
                          final isLoadingState = isAuthLoading || _isLoading;

                          return AuthButton(
                            text: 'Send OTP',
                            onPressed: isLoadingState ? null : _sendOtp,
                            isLoading: isLoadingState,
                            isTablet: isTablet,
                            icon: Icons.sms,
                          );
                        },
                      ),

                      SizedBox(height: isTablet ? 32 : 24),

                      // Login Method Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Want to use password? ',
                            style: TextStyle(
                              fontSize: isTablet ? 16 : 14,
                              color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PasswordLoginScreen(),
                              ),
                            ),
                            child: Text(
                              'Login with Password',
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
      ),
    );
  }
}
