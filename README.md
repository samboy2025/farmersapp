# ChatWave - WhatsApp Clone

A comprehensive WhatsApp clone built with Flutter, featuring modern UI/UX, real-time messaging, voice/video calls, and more.

## 🚀 Features

### Core Messaging
- **Text Messages** with emoji support
- **Media Sharing** (images, videos, documents)
- **Voice Messages** with recording capabilities
- **Location Sharing** with map integration
- **Contact Sharing** via vCard
- **Group Chats** with participant management
- **Message Status** (sent, delivered, read)

### Authentication & Security
- **Phone Number Verification** with OTP
- **Secure Authentication** using JWT tokens
- **User Profile Management**

### Communication Features
- **Real-time Messaging** via WebSocket
- **Voice Calls** using WebRTC
- **Video Calls** with camera integration
- **Call History** and management

### User Experience
- **Modern Material Design 3** UI
- **Dark/Light Theme** support
- **Responsive Design** for all screen sizes
- **Smooth Animations** and transitions
- **Offline Support** with message queuing

## 🏗️ Architecture

### State Management
- **BLoC Pattern** for predictable state management
- **Repository Pattern** for data abstraction
- **Clean Architecture** principles

### Key Components
```
lib/
├── blocs/           # Business Logic Components
│   ├── auth/       # Authentication state management
│   ├── chat/       # Chat and messaging logic
│   ├── call/       # Voice/video call management
│   └── profile/    # User profile management
├── models/          # Data models
├── repositories/    # Data access layer
├── screens/         # UI screens
├── widgets/         # Reusable UI components
└── config/          # App configuration and themes
```

## 🛠️ Technology Stack

- **Framework**: Flutter 3.8+
- **Language**: Dart
- **State Management**: flutter_bloc 8.1.3
- **HTTP Client**: Dio
- **Real-time**: WebSocket
- **Calls**: WebRTC (flutter_webrtc)
- **Media**: image_picker, file_picker
- **Audio**: record package
- **Location**: location package
- **Permissions**: permission_handler

## 📱 Screenshots

### Authentication Flow
- Splash Screen with animated logo
- Phone number input
- OTP verification

### Main App
- Chats list with search and options
- Individual chat with message bubbles
- Contacts management
- Call history
- User profile with editing capabilities

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8+
- Dart SDK
- Android Studio / VS Code
- Android SDK / Xcode (for mobile development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/chatwave.git
   cd chatwave
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure backend**
   - Update `lib/config/app_config.dart` with your backend URLs
   - Ensure your Laravel backend is running and accessible

4. **Run the app**
   ```bash
   flutter run
   ```

### Backend Requirements

The app expects a Laravel backend with the following endpoints:

#### Authentication
- `POST /auth/send-otp` - Send OTP to phone number
- `POST /auth/verify-otp` - Verify OTP and get token
- `POST /auth/logout` - Logout user
- `POST /auth/refresh` - Refresh authentication token

#### Chat Management
- `GET /chats` - Get user's chat list
- `GET /chats/{id}/messages` - Get messages for a chat
- `POST /chats/{id}/messages` - Send a message
- `PUT /chats/{id}/messages/{messageId}/read` - Mark message as read
- `POST /chats/group` - Create group chat
- `PUT /chats/{id}/pin` - Pin/unpin chat

#### WebSocket
- `ws://your-domain/ws` - Real-time messaging endpoint

## 🔧 Configuration

### Environment Variables
Update the following in `lib/config/app_config.dart`:

```dart
static const String baseUrl = 'https://your-backend-domain.com';
static const String wsUrl = 'wss://your-backend-domain.com';
```

### Permissions
The app requires the following permissions:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.READ_CONTACTS" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos and videos</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access for voice messages and calls</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to share your location</string>
<key>NSContactsUsageDescription</key>
<string>This app needs contacts access to share contacts</string>
```

## 📁 Project Structure

```
lib/
├── blocs/                    # State management
│   ├── auth/                # Authentication logic
│   ├── chat/                # Chat and messaging
│   ├── call/                # Voice/video calls
│   └── profile/             # User profile
├── models/                   # Data models
│   ├── user.dart            # User model
│   ├── chat.dart            # Chat model
│   ├── message.dart         # Message model
│   └── call.dart            # Call model
├── repositories/             # Data access
│   ├── auth_repository.dart # Auth API calls
│   └── chat_repository.dart # Chat API calls
├── screens/                  # UI screens
│   ├── auth/                # Authentication screens
│   ├── home/                # Main app screens
│   └── chat/                # Chat interface
├── widgets/                  # Reusable components
├── config/                   # App configuration
└── main.dart                # App entry point
```

## 🎨 Customization

### Themes
The app supports both light and dark themes. Customize colors in `lib/config/app_config.dart`:

```dart
class AppConfig {
  static const Color primaryColor = Color(0xFF128C7E);    // WhatsApp green
  static const Color secondaryColor = Color(0xFF25D366);  // Light green
  static const Color accentColor = Color(0xFF34B7F1);     // Blue
}
```

### Styling
- Update `AppTheme.lightTheme` and `AppTheme.darkTheme`
- Modify `AppConfig` constants for dimensions and durations
- Customize message bubble styles in `MessageBubble` widget

## 🧪 Testing

Run tests with:
```bash
flutter test
```

The project includes unit tests for:
- BLoC logic
- Model serialization
- Repository methods

## 📦 Building

### Android APK
```bash
flutter build apk --release
```

### iOS IPA
```bash
flutter build ios --release
```

### Web
```bash
flutter build web
```

## 🔒 Security Features

- **JWT Authentication** for secure API access
- **HTTPS/WSS** for encrypted communication
- **Permission-based** access to device features
- **Input validation** and sanitization

## 🚧 Roadmap

### Phase 1 (Current)
- ✅ Basic messaging functionality
- ✅ User authentication
- ✅ Chat interface
- ✅ Profile management

### Phase 2 (Next)
- 🔄 Real-time messaging via WebSocket
- 🔄 Media file handling
- 🔄 Voice message recording
- 🔄 Location sharing

### Phase 3 (Future)
- 📋 Voice and video calls
- 📋 Group chat management
- 📋 Message encryption
- 📋 Push notifications
- 📋 File sharing
- 📋 Message search
- 📋 Chat backup/restore

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **BLoC Library** for state management
- **WhatsApp** for inspiration and UI patterns
- **Open Source Community** for various packages

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/chatwave/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/chatwave/discussions)
- **Email**: support@chatwave.com

## 🔗 Links

- **Website**: [https://chatwave.com](https://chatwave.com)
- **Documentation**: [https://docs.chatwave.com](https://docs.chatwave.com)
- **API Reference**: [https://api.chatwave.com/docs](https://api.chatwave.com/docs)

---

**Made with ❤️ using Flutter**
