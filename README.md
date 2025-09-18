# ChatWave - WhatsApp Clone

A comprehensive WhatsApp clone built with Flutter, featuring modern UI/UX, real-time messaging, voice/video calls, and more.

## 🚀 Features

### 📱 Core Messaging
- ✅ **Text Messages** with emoji support and rich formatting
- ✅ **Media Sharing** (images, videos, documents, files)
- ✅ **Voice Messages** with recording capabilities and waveform visualization
- ✅ **Location Sharing** with map integration and coordinates
- ✅ **Contact Sharing** via vCard with phone number integration
- ✅ **Group Chats** with participant management and admin controls
- ✅ **Message Status** indicators (sent, delivered, read)
- ✅ **Message Search** with filtering and highlighting
- ✅ **Message Forwarding** to multiple contacts
- ✅ **Message Reactions** with emoji responses
- ✅ **Message Threading** and reply functionality

### 🔐 Authentication & Security
- ✅ **Phone Number Registration** with multi-step form
- ✅ **Password Authentication** with secure login
- ✅ **OTP Verification** for phone number validation
- ✅ **Forgot Password** recovery system
- ✅ **User Profile Management** with photo and bio editing
- ✅ **Privacy Controls** (last seen, profile photo, about visibility)
- ✅ **Secure Authentication** using JWT tokens
- ✅ **State-based Registration** (Nigeria states integration)

### 📞 Communication Features
- ✅ **Voice Calls** using WebRTC with high-quality audio
- ✅ **Video Calls** with camera integration and switching
- ✅ **Call History** with detailed logs and filtering
- ✅ **Call Controls** (mute, speaker, video toggle, camera switch)
- ✅ **Incoming Call Screen** with accept/reject functionality
- ✅ **Call Duration Tracking** with real-time timer
- ✅ **Call Quality Indicators** and network status
- ✅ **Group Video Calls** with multi-participant support
- ✅ **Call Recording** capabilities (planned)

### 📊 Status System
- ✅ **Text Status** creation with rich formatting and backgrounds
- ✅ **Image Status** with gallery and camera integration
- ✅ **Video Status** with recording and playback
- ✅ **Status Privacy Controls** (public, contacts only, custom)
- ✅ **Status Analytics** with view tracking and insights
- ✅ **Status Archive** for expired statuses
- ✅ **Auto-expiration** (24-hour lifecycle)
- ✅ **Status Reactions** and engagement tracking
- ✅ **Status Forwarding** and sharing
- ✅ **Status Reply** functionality

### 👥 Contact & Group Management
- ✅ **Contact List** with phone book integration
- ✅ **Contact Details** with comprehensive information
- ✅ **Group Creation** and management
- ✅ **Community Features** with advanced group controls
- ✅ **Member Management** (add, remove, promote, demote)
- ✅ **Group Settings** and privacy controls
- ✅ **QR Code Sharing** for easy contact addition
- ✅ **Contact Blocking** and reporting functionality

### 🎨 User Experience & Interface
- ✅ **Modern Material Design 3** UI with beautiful gradients
- ✅ **Dark/Light Theme** support with smooth transitions
- ✅ **Responsive Design** optimized for phones and tablets
- ✅ **Smooth Animations** and micro-interactions
- ✅ **Custom Chat Wallpapers** and background customization
- ✅ **Font Size Adjustment** for accessibility
- ✅ **Language Support** (English, Spanish, French, German, Chinese)
- ✅ **Accessibility Features** with screen reader support
- ✅ **Gesture Controls** for intuitive navigation

### ⚙️ Settings & Configuration
- ✅ **Comprehensive Settings** with organized sections
- ✅ **Notification Management** (message, call, status notifications)
- ✅ **Privacy Settings** (read receipts, typing indicators, last seen)
- ✅ **Chat Settings** (auto-download, backup, wallpaper)
- ✅ **Call Settings** with preferences and history
- ✅ **Appearance Customization** (theme, language, font size)
- ✅ **Help Center** with support and documentation
- ✅ **Privacy Policy** and terms of service
- ✅ **App Information** and version details

### 📁 Media & File Management
- ✅ **Image Picker** with camera and gallery integration
- ✅ **Video Recording** with quality controls
- ✅ **File Sharing** with document support
- ✅ **Media Compression** for optimal storage
- ✅ **Media Gallery** with organized viewing
- ✅ **Permission Management** for camera, storage, contacts
- ✅ **Image Processing** with compression and validation
- ✅ **Multiple Image Selection** for batch sharing

### 🔧 Technical Features
- ✅ **BLoC State Management** for predictable app behavior
- ✅ **Repository Pattern** for clean data abstraction
- ✅ **WebSocket Integration** for real-time communication
- ✅ **WebRTC Implementation** for high-quality calls
- ✅ **Offline Support** with message queuing
- ✅ **Error Handling** with user-friendly messages
- ✅ **Performance Optimization** with lazy loading
- ✅ **Memory Management** for smooth operation
- ✅ **Cross-platform Support** (Android, iOS, Web, Desktop)

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

### 🔐 Authentication Flow
- **Splash Screen** with animated logo and loading
- **Registration Screen** with multi-step form (Personal Info → State Selection → Security)
- **Login Screen** with phone number and password authentication
- **OTP Verification** for phone number validation
- **Forgot Password** recovery system

### 💬 Messaging & Chat
- **Chats List** with search, unread counts, and pin functionality
- **Individual Chat** with message bubbles, media sharing, and voice messages
- **Group Chat** with participant management and admin controls
- **Message Search** with filtering and highlighting
- **Media Gallery** for organized photo/video viewing
- **Location Sharing** with map integration
- **Contact Sharing** via vCard

### 📞 Calls & Communication
- **Call History** with detailed logs and filtering by type
- **Incoming Call Screen** with accept/reject and message reply options
- **Active Call Screen** with controls (mute, speaker, video toggle)
- **Video Call** with camera switching and picture-in-picture
- **Call Initiation** with ringing and connection status

### 📊 Status System
- **Status List** with recent and viewed updates
- **Status Creation** with text formatting, image/video upload
- **Status Viewing** with full-screen auto-play experience
- **Status Analytics** with view tracking and engagement metrics
- **Status Archive** for expired statuses
- **Privacy Settings** for status visibility control

### 👥 Contacts & Groups
- **Contact List** with phone book integration
- **Contact Details** with comprehensive information and quick actions
- **Community Management** with advanced group controls
- **Group Settings** with member management and privacy controls
- **QR Code Scanner** for easy contact addition

### ⚙️ Settings & Configuration
- **Settings Dashboard** with organized sections
- **Profile Management** with photo and bio editing
- **Notification Settings** for messages, calls, and status
- **Privacy Controls** (read receipts, typing indicators, last seen)
- **Appearance Settings** (theme, language, font size, wallpaper)
- **Help Center** with support and documentation

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8+
- Dart SDK
- Android Studio / VS Code
- Android SDK / Xcode (for mobile development)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Samboy2022/chat_app2.git
   cd chat_app2
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

## 🚧 Implementation Status

### ✅ Phase 1 - Core Features (Completed)
- ✅ **Authentication System** - Phone registration, OTP verification, password login
- ✅ **Basic Messaging** - Text messages with emoji support and rich formatting
- ✅ **Media Sharing** - Images, videos, documents with compression
- ✅ **Voice Messages** - Recording with waveform visualization
- ✅ **Location Sharing** - Map integration with coordinates
- ✅ **Contact Sharing** - vCard with phone number integration
- ✅ **User Profile** - Photo, bio, and privacy settings management

### ✅ Phase 2 - Advanced Features (Completed)
- ✅ **Status System** - Text, image, video statuses with privacy controls
- ✅ **Call System** - Voice and video calls with WebRTC
- ✅ **Group Management** - Creation, member management, admin controls
- ✅ **Call History** - Detailed logs with filtering and statistics
- ✅ **Message Search** - Filtering and highlighting functionality
- ✅ **Settings Dashboard** - Comprehensive configuration options
- ✅ **Media Gallery** - Organized photo/video viewing
- ✅ **Status Analytics** - View tracking and engagement metrics

### ✅ Phase 3 - Enhanced Features (Completed)
- ✅ **Real-time Communication** - WebSocket integration for live updates
- ✅ **Advanced UI/UX** - Material Design 3 with animations
- ✅ **Theme System** - Dark/light mode with smooth transitions
- ✅ **Responsive Design** - Optimized for phones and tablets
- ✅ **Permission Management** - Camera, storage, contacts, location
- ✅ **Error Handling** - User-friendly error messages and recovery
- ✅ **Cross-platform Support** - Android, iOS, Web, Desktop

### 🔄 Phase 4 - Future Enhancements (Planned)
- 📋 **Push Notifications** - Real-time alerts and updates
- 📋 **Message Encryption** - End-to-end encryption for security
- 📋 **Cloud Backup** - Automatic chat and media backup
- 📋 **Advanced Analytics** - Detailed usage and performance metrics
- 📋 **Multi-language Support** - Localization for global users
- 📋 **Custom Themes** - User-defined color schemes and wallpapers
- 📋 **Voice Transcription** - Automatic speech-to-text conversion
- 📋 **File Compression** - Advanced media optimization
- 📋 **Offline Sync** - Complete offline functionality with sync
- 📋 **Group Video Calls** - Multi-participant video conferencing

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

- **Issues**: [GitHub Issues](https://github.com/Samboy2022/chat_app2/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Samboy2022/chat_app2/discussions)
- **Email**: support@chatwave.com

## 🔗 Links

- **Website**: [https://chatwave.com](https://chatwave.com)
- **Documentation**: [https://docs.chatwave.com](https://docs.chatwave.com)
- **API Reference**: [https://api.chatwave.com/docs](https://api.chatwave.com/docs)

---

**Made with ❤️ using Flutter**

![CodeRabbit Pull Request Reviews](https://img.shields.io/coderabbit/prs/github/Samboy2022/chat_app2?utm_source=oss&utm_medium=github&utm_campaign=Samboy2022%2Fchat_app2&labelColor=171717&color=FF570A&link=https%3A%2F%2Fcoderabbit.ai&label=CodeRabbit+Reviews)
