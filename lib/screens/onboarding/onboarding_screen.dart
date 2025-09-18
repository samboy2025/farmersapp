import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/app_config.dart';
import '../../utils/animation_utils.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Welcome to ChatWave',
      description: 'Connect with friends and family through secure messaging, voice calls, and video chats.',
      image: 'assets/images/onboarding/welcome.svg',
      icon: Icons.waving_hand,
    ),
    OnboardingData(
      title: 'Stay Connected',
      description: 'Share photos, videos, documents and your current location with end-to-end encryption.',
      image: 'assets/images/onboarding/connected.svg',
      icon: Icons.connect_without_contact,
    ),
    OnboardingData(
      title: 'Group Conversations',
      description: 'Create groups to chat with multiple people and stay connected with communities.',
      image: 'assets/images/onboarding/groups.svg',
      icon: Icons.groups,
    ),
    OnboardingData(
      title: 'Voice & Video Calls',
      description: 'Make crystal clear voice and video calls to anyone, anywhere in the world.',
      image: 'assets/images/onboarding/calls.svg',
      icon: Icons.videocam,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: AppConfig.mediumAnimation,
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: AppConfig.mediumAnimation,
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeOnboarding() {
    // Navigate to login screen after onboarding completion
    Navigator.of(context).pushReplacement(
      SmoothPageRoute(
        page: const LoginScreen(),
        beginOffset: const Offset(0, 1),
        curve: AppAnimationCurves.pageEnter,
      ),
    );
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<bool> _checkSvgExists(String assetPath) async {
    try {
      await DefaultAssetBundle.of(context).loadString(assetPath);
      return true;
    } catch (e) {
      return false;
    }
  }

  Widget _buildFallbackIcon(OnboardingData data, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: AppConfig.primaryColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        data.icon,
        size: isTablet ? 60 : 48,
        color: AppConfig.primaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.darkBackground : Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            _buildTopBar(),
            
            // Content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(_onboardingData[index], isTablet);
                },
              ),
            ),
            
            // Bottom section
            _buildBottomSection(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo/App name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppConfig.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.chat_bubble,
                  color: AppConfig.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                AppConfig.appName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111B21),
                ),
              ),
            ],
          ),
          
          // Skip button
          TextButton(
            onPressed: _skipOnboarding,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF667781),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Skip',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingData data, bool isTablet) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 60 : 24,
          vertical: 20,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon/Illustration
            Container(
              width: isTablet ? 200 : 160,
              height: isTablet ? 200 : 160,
              child: FutureBuilder<bool>(
                future: _checkSvgExists(data.image),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.data == true) {
                    return SvgPicture.asset(
                      data.image,
                      width: isTablet ? 120 : 100,
                      height: isTablet ? 120 : 100,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildFallbackIcon(data, isTablet);
                      },
                    );
                  } else {
                    return _buildFallbackIcon(data, isTablet);
                  }
                },
              ),
            ),
            
            SizedBox(height: isTablet ? 60 : 48),
            
            // Title
            Text(
              data.title,
              style: TextStyle(
                fontSize: isTablet ? 32 : 28,
                fontWeight: FontWeight.w700,
                color: isDark ? AppConfig.darkText : const Color(0xFF111B21),
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: isTablet ? 24 : 20),
            
            // Description
            Text(
              data.description,
              style: TextStyle(
                fontSize: isTablet ? 18 : 16,
                color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 32 : 24),
      child: Column(
        children: [
          // Page indicators
          _buildPageIndicators(),
          
          SizedBox(height: isTablet ? 32 : 24),
          
          // Navigation buttons
          Row(
            children: [
              // Previous button
              if (_currentPage > 0)
                Expanded(
                  flex: 1,
                  child: OutlinedButton(
                    onPressed: _previousPage,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppConfig.primaryColor),
                      foregroundColor: AppConfig.primaryColor,
                      padding: EdgeInsets.symmetric(
                        vertical: isTablet ? 16 : 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Previous',
                      style: TextStyle(
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              
              if (_currentPage > 0) SizedBox(width: isTablet ? 20 : 16),
              
              // Next/Get Started button
              Expanded(
                flex: _currentPage > 0 ? 2 : 1,
                child: ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConfig.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 16 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentPage == _onboardingData.length - 1 
                        ? 'Get Started'
                        : 'Next',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _onboardingData.length,
        (index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: _currentPage == index 
                ? AppConfig.primaryColor 
                : AppConfig.primaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String image;
  final IconData icon;

  OnboardingData({
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
  });
}
