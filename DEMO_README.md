# ChatWave Demo Mode

## Overview
This is a demo version of ChatWave that bypasses all API connections and uses mock data to showcase the app's functionality.

## What's Been Implemented

### ✅ Demo Mode Features
- **Bypass Authentication**: App goes directly to home screen after splash
- **Mock Data Service**: Complete mock data for users, chats, and messages
- **No API Dependencies**: All network calls replaced with local mock data
- **Realistic Delays**: Simulated API delays for authentic feel

### ✅ Available Screens
1. **Splash Screen** - Shows app logo and demo mode indicator
2. **Home Screen** - Bottom navigation with 4 tabs
3. **Chats List** - Shows mock conversations
4. **Contacts Screen** - Displays mock user contacts
5. **Calls Screen** - Call history and dialer
6. **Profile Screen** - User profile with mock data
7. **Chat Screen** - Individual chat conversations
8. **Message Components** - Text, image, and file message support

### ✅ Mock Data
- **5 Demo Users**: John Doe, Jane Smith, Mike Johnson, Sarah Wilson, David Brown
- **4 Demo Chats**: 3 individual chats + 1 group chat
- **Sample Messages**: Text and image messages with realistic timestamps
- **User Profiles**: Complete user information with status and last seen

## How to Run

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Android Studio / VS Code
- Android emulator or physical device

### Setup
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the app

### Demo Flow
1. **Splash Screen**: 3-second animation with demo mode indicator
2. **Home Screen**: Automatically loads with mock chat data
3. **Navigation**: Use bottom tabs to explore different sections
4. **Chats**: Tap on any chat to view conversation
5. **Profile**: View and edit user profile (changes are local only)

## Demo Credentials
- **Phone Number**: +1234567890
- **OTP**: Any 4+ digit code (e.g., 1234, 5678)

## Features Available in Demo

### Chat Features
- ✅ View chat list
- ✅ Open individual chats
- ✅ Send text messages
- ✅ View message history
- ✅ Message status indicators
- ✅ Chat pinning (simulated)

### Profile Features
- ✅ View user profile
- ✅ Edit name and about
- ✅ Profile picture (simulated)
- ✅ Online/offline status

### Contact Features
- ✅ View contact list
- ✅ User status and last seen
- ✅ Contact verification badges

### Call Features
- ✅ Call history view
- ✅ Dialer interface
- ✅ Call controls (simulated)

## Technical Implementation

### Mock Data Service
- **Location**: `lib/services/mock_data_service.dart`
- **Purpose**: Provides static mock data for all app features
- **Data Types**: Users, Chats, Messages, User Status

### Demo Configuration
- **Location**: `lib/config/demo_config.dart`
- **Purpose**: Centralized demo mode settings
- **Features**: Toggle demo features, configure delays

### Modified Blocs
- **AuthBloc**: Simulates OTP verification
- **ChatBloc**: Uses mock data instead of API calls
- **ProfileBloc**: Local profile management
- **CallBloc**: Simulated call functionality

## Customization

### Adding More Mock Data
1. Edit `lib/services/mock_data_service.dart`
2. Add new users, chats, or messages
3. Update the mock data arrays

### Changing Demo Delays
1. Edit `lib/config/demo_config.dart`
2. Modify delay durations
3. Restart the app

### Disabling Demo Mode
1. Set `DemoConfig.isDemoMode = false` in `demo_config.dart`
2. Restore API connections in blocs
3. Update repository dependencies

## Known Limitations

### Demo Mode Constraints
- All data is static and resets on app restart
- No real-time updates or notifications
- File uploads are simulated
- Calls are not functional (UI only)
- No actual WebSocket connections

### UI Considerations
- Some features show loading states briefly
- Error handling is minimal
- Network status indicators are simulated

## Future Enhancements

### Potential Improvements
- Persistent local storage for demo data
- More realistic mock data scenarios
- Interactive demo tutorials
- Feature comparison with production version
- Export/import demo data

## Support

For questions about the demo mode or to report issues:
- Check the Flutter console for any error messages
- Verify all dependencies are properly installed
- Ensure Flutter SDK version compatibility

---

**Note**: This is a demonstration version. For production use, restore API connections and remove mock data dependencies.
