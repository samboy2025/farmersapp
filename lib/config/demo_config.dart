class DemoConfig {
  // Demo mode settings
  static const bool isDemoMode = true;
  static const bool bypassAuthentication = true;
  static const bool useMockData = true;
  
  // Demo user credentials (for testing)
  static const String demoPhoneNumber = '+1234567890';
  static const String demoOtp = '1234';
  
  // Demo delays (to simulate real API calls)
  static const Duration loginDelay = Duration(seconds: 1);
  static const Duration otpVerificationDelay = Duration(seconds: 1);
  static const Duration chatLoadDelay = Duration(milliseconds: 500);
  static const Duration messageSendDelay = Duration(milliseconds: 500);
  static const Duration profileLoadDelay = Duration(milliseconds: 500);
  
  // Demo features enabled
  static const bool enableChats = true;
  static const bool enableCalls = true;
  static const bool enableProfile = true;
  static const bool enableContacts = true;
  
  // Demo data settings
  static const int maxDemoChats = 10;
  static const int maxDemoMessages = 50;
  static const int maxDemoUsers = 20;
}
