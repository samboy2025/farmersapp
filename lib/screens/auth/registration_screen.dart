import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_config.dart';
import '../../widgets/auth/auth_input_field.dart';
import '../../widgets/auth/auth_button.dart';
import '../../widgets/auth/auth_header.dart';
import '../../widgets/auth/auth_dropdown.dart';
import '../../services/nigeria_api_service.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  final NigeriaApiService _nigeriaService = NigeriaApiService();

  // Controllers
  final _fullNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State variables
  String? _selectedState;
  String? _selectedLGA;
  List<String> _availableStates = [];
  List<String> _availableLGAs = [];
  int _currentStep = 0;
  bool _isLoading = false;
  bool _isLoadingStates = true;
  bool _isLoadingLGAs = false;
  bool _acceptedTerms = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStates();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadStates() async {
    setState(() {
      _isLoadingStates = true;
      _errorMessage = null;
    });

    try {
      final states = await _nigeriaService.getStates();
      setState(() {
        _availableStates = states;
        _isLoadingStates = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load states. Please try again.';
        _isLoadingStates = false;
        // Use fallback states
        _availableStates = _nigeriaService.getFallbackStates();
      });
    }
  }

  Future<void> _loadLGAs(String state) async {
    setState(() {
      _isLoadingLGAs = true;
      _availableLGAs = [];
      _errorMessage = null;
    });

    try {
      final lgas = await _nigeriaService.getLGAs(state);
      setState(() {
        _availableLGAs = lgas;
        _isLoadingLGAs = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load LGAs. Please try again.';
        _isLoadingLGAs = false;
        // Use fallback LGAs
        _availableLGAs = _nigeriaService.getFallbackLGAs(state);
      });
    }
  }

  void _onStateChanged(String? state) {
    setState(() {
      _selectedState = state;
      _selectedLGA = null;
      _availableLGAs = [];
    });

    if (state != null) {
      _loadLGAs(state);
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      if (_validateCurrentStep()) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _register();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _validatePersonalInfo();
      case 1:
        return _validateLocationInfo();
      case 2:
        return _validateSecurityInfo();
      default:
        return false;
    }
  }

  bool _validatePersonalInfo() {
    if (_fullNameController.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return false;
    }
    if (_phoneNumberController.text.trim().isEmpty) {
      _showError('Please enter your phone number');
      return false;
    }
    if (_phoneNumberController.text.trim().length < 11) {
      _showError('Please enter a valid phone number');
      return false;
    }
    return true;
  }

  bool _validateLocationInfo() {
    if (_selectedState == null) {
      _showError('Please select your state');
      return false;
    }
    if (_selectedLGA == null) {
      _showError('Please select your local government area');
      return false;
    }
    return true;
  }

  bool _validateSecurityInfo() {
    if (_passwordController.text.trim().isEmpty) {
      _showError('Please enter a password');
      return false;
    }
    if (_passwordController.text.trim().length < 6) {
      _showError('Password must be at least 6 characters');
      return false;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showError('Passwords do not match');
      return false;
    }
    if (!_acceptedTerms) {
      _showError('Please accept the terms and conditions');
      return false;
    }
    return true;
  }

  Future<void> _refreshNigeriaData() async {
    setState(() {
      _isLoadingStates = true;
      _availableStates = [];
      _availableLGAs = [];
      _selectedState = null;
      _selectedLGA = null;
      _errorMessage = null;
    });

    try {
      await _nigeriaService.refreshData();

      // Reload the data
      final states = await _nigeriaService.getStates();
      setState(() {
        _availableStates = states;
        _isLoadingStates = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Data refreshed successfully!'),
          backgroundColor: AppConfig.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } catch (e) {
      setState(() {
        _isLoadingStates = false;
        _errorMessage = 'Failed to refresh data. Please try again.';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to refresh data. Using cached data if available.'),
          backgroundColor: AppConfig.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConfig.errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _register() async {
    if (!_validateCurrentStep()) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate registration process
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
    });

    // Show success and navigate to login
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Registration successful! Please login.'),
        backgroundColor: AppConfig.successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );

    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.darkBackground : AppConfig.lightBackground,
      appBar: AuthAppBar(
        title: 'Create Account',
        showBackButton: _currentStep > 0,
        onBackPressed: _previousStep,
        isTablet: isTablet,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 32 : 24),
          child: Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(isTablet),

              // Refresh data button (only show when states are loaded)
              if (_availableStates.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: _refreshNigeriaData,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Refresh Data'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppConfig.primaryColor,
                        textStyle: TextStyle(fontSize: isTablet ? 14 : 12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 16 : 12),
              ],

              SizedBox(height: isTablet ? 32 : 24),
              
              // Form content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildPersonalInfoStep(isTablet),
                    _buildLocationStep(isTablet),
                    _buildSecurityStep(isTablet),
                  ],
                ),
              ),
              
              SizedBox(height: isTablet ? 24 : 16),
              
              // Navigation buttons
              _buildNavigationButtons(isTablet),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isTablet) {
    return Row(
      children: List.generate(3, (index) {
        return Expanded(
          child: Container(
            height: isTablet ? 6 : 4,
            margin: EdgeInsets.only(right: index < 2 ? (isTablet ? 12 : 8) : 0),
            decoration: BoxDecoration(
              color: index <= _currentStep
                  ? AppConfig.primaryColor
                  : const Color(0xFFE5E5E5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPersonalInfoStep(bool isTablet) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthHeader(
              title: 'Personal Information',
              subtitle: 'Tell us about yourself',
              showLogo: false,
              isTablet: isTablet,
            ),
            
            SizedBox(height: isTablet ? 40 : 32),
            
            AuthInputField(
              label: 'Full Name',
              hint: 'Enter your full name',
              controller: _fullNameController,
              prefixIcon: Icons.person_outline,
              keyboardType: TextInputType.name,
              isTablet: isTablet,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            
            SizedBox(height: isTablet ? 24 : 20),
            
            AuthInputField(
              label: 'Phone Number',
              hint: '08012345678',
              controller: _phoneNumberController,
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
                if (value.length < 11) {
                  return 'Phone number must be 11 digits';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStep(bool isTablet) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthHeader(
            title: 'Location Details',
            subtitle: 'Help us know where you are located',
            showLogo: false,
            isTablet: isTablet,
          ),
          
          SizedBox(height: isTablet ? 40 : 32),
          
          if (_isLoadingStates)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null && _availableStates.isEmpty)
            Column(
              children: [
                Text(
                  _errorMessage!,
                  style: TextStyle(color: AppConfig.errorColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                AuthButton(
                  text: 'Retry',
                  onPressed: _loadStates,
                  isTablet: isTablet,
                ),
              ],
            )
          else
            AuthDropdown(
              label: 'State',
              hint: 'Select your state',
              items: _availableStates,
              value: _selectedState,
              onChanged: _onStateChanged,
              prefixIcon: Icons.location_on_outlined,
              isTablet: isTablet,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your state';
                }
                return null;
              },
            ),
          
          SizedBox(height: isTablet ? 24 : 20),
          
          if (_selectedState == null)
            AuthDropdown(
              label: 'Local Government Area (LGA)',
              hint: 'Please select a state first',
              items: const [],
              value: null,
              onChanged: (_) {},
              prefixIcon: Icons.location_city_outlined,
              isTablet: isTablet,
              validator: (value) {
                if (_selectedState == null) {
                  return 'Please select your state first';
                }
                if (value == null || value.isEmpty) {
                  return 'Please select your LGA';
                }
                return null;
              },
            )
          else if (_isLoadingLGAs)
            const Center(child: CircularProgressIndicator())
          else if (_availableLGAs.isEmpty)
            Column(
              children: [
                Text(
                  'No LGAs available for $_selectedState',
                  style: TextStyle(color: AppConfig.errorColor),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                AuthButton(
                  text: 'Retry',
                  onPressed: () => _loadLGAs(_selectedState!),
                  isTablet: isTablet,
                ),
              ],
            )
          else
            AuthDropdown(
              label: 'Local Government Area (LGA)',
              hint: 'Select your LGA',
              items: _availableLGAs,
              value: _selectedLGA,
              onChanged: (value) {
                setState(() {
                  _selectedLGA = value;
                });
              },
              prefixIcon: Icons.location_city_outlined,
              isTablet: isTablet,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your LGA';
                }
                return null;
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSecurityStep(bool isTablet) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthHeader(
            title: 'Security Setup',
            subtitle: 'Create a secure password for your account',
            showLogo: false,
            isTablet: isTablet,
          ),
          
          SizedBox(height: isTablet ? 40 : 32),
          
          AuthInputField(
            label: 'Password',
            hint: 'Create a strong password',
            controller: _passwordController,
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            isTablet: isTablet,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          
          SizedBox(height: isTablet ? 24 : 20),
          
          AuthInputField(
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            controller: _confirmPasswordController,
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            isTablet: isTablet,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          
          SizedBox(height: isTablet ? 32 : 24),
          
          // Terms and conditions
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: isTablet ? 28 : 24,
                height: isTablet ? 28 : 24,
                child: Checkbox(
                  value: _acceptedTerms,
                  onChanged: (value) {
                    setState(() {
                      _acceptedTerms = value ?? false;
                    });
                  },
                  activeColor: AppConfig.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Expanded(
                child: Text.rich(
                  TextSpan(
                    text: 'I agree to the ',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
                    ),
                    children: [
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(
                          color: AppConfig.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(
                          color: AppConfig.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(bool isTablet) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        AuthButton(
          text: _currentStep < 2 ? 'Next' : 'Create Account',
          onPressed: _nextStep,
          isLoading: _isLoading,
          isTablet: isTablet,
          icon: _currentStep < 2 ? Icons.arrow_forward : Icons.check,
        ),
        
        if (_currentStep > 0) ...[
          SizedBox(height: isTablet ? 16 : 12),
          AuthButton(
            text: 'Back',
            onPressed: _previousStep,
            isSecondary: true,
            isTablet: isTablet,
            icon: Icons.arrow_back,
          ),
        ],
        
        SizedBox(height: isTablet ? 24 : 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Already have an account? ',
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(context, '/login'),
              child: Text(
                'Sign In',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: AppConfig.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
