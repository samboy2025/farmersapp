# PROJECT METADATA
project_name: "ChatWave"
framework: "Flutter"
target_platforms: ["iOS", "Android"]
state_management: "Bloc (flutter_bloc 8.1.3)"
null_safety: "enabled"

# CORE TECHNICAL ARCHITECTURE
architecture: "Layered (Presentation -> Bloc -> Repository -> Data Sources)"
data_sources:
  - "Laravel REST API (Backend-to-be)"
  - "WebSocket for real-time messages & call signaling"
  - "Local device storage (for picking files)"

# CRITICAL EXTERNAL PACKAGES (Add as dependencies)
dependencies:
  - flutter_bloc: ^8.1.3
  - equatable: ^2.0.5
  - dio: ^5.4.0
  - web_socket_channel: ^2.4.0
  - flutter_webrtc: ^0.10.0
  - image_picker: ^1.0.4
  - file_picker: ^5.5.0
  - location: ^4.4.0
  - permission_handler: ^11.0.1
  - cached_network_image: ^3.3.0
  - emoji_picker_flutter: ^2.1.1
  - record: ^5.0.1

# KEY FEATURE MODULES
features:
  - authentication
  - one-to-one_chat
  - group_chat
  - user_profile
  - voice_call
  - video_call

# DETAILED FEATURE SPECIFICATIONS

## 1. AUTHENTICATION
description: "Phone number-based login with OTP."
ui_flow: "SplashPage -> LoginPage (enter phone) -> OtpVerificationPage -> HomePage"
blocs: ["AuthBloc"]
states: ["AuthInitial", "AuthLoading", "AuthSuccess", "AuthFailure"]
events: ["AuthLoginRequested", "AuthOtpVerified", "AuthLogoutRequested"]

## 2. CHAT MODULE
description: "Core messaging functionality supporting multiple message types."
message_types: ["text", "image", "video", "file", "contact", "location", "voice_message"]
ui_components:
  - "ChatsListPage"
  - "ChatScreen (shows messages)"
  - "MessageBubble (widget, type-specific UI)"
  - "ChatInputToolbar (with attachment bottom sheet)"
blocs: ["ChatBloc", "MessageBloc"]
states: ["ChatsLoadSuccess", "MessagesLoadSuccess", "MessageSending", "MessageSent", "MessageError"]
events: ["ChatsFetched", "MessageSent", "MessageReceived", "AttachmentSelected"]

## 3. PROFILE MODULE
description: "View and edit user profile."
ui_flow: "Drawer -> ProfilePage -> EditProfilePage"
blocs: ["ProfileBloc"]
states: ["ProfileLoadSuccess", "ProfileUpdating", "ProfileUpdateSuccess", "ProfileUpdateFailure"]
events: ["ProfileFetched", "ProfileUpdateRequested"]

## 4. CALL MODULE
description: "Voice and Video calling using WebRTC."
ui_screens:
  - "IncomingCallScreen (full-screen overlay)"
  - "ActiveCallScreen (with controls, PiP for video)"
  - "CallingScreen (outgoing call)"
blocs: ["CallBloc"]
states: ["CallInitial", "CallDialing", "CallIncoming", "CallConnected", "CallEnded", "CallFailure"]
events: ["CallInitiated", "CallAnswered", "CallHungUp", "CallRejected"]
technical: "Relies on `flutter_webrtc`. Signaling is handled via WebSocket from Laravel backend."

# UI/UX GUIDELINES
theme: "Dark mode primary, with light mode support."
brand_color: "Shades of green (#128C7E), red for end call, green for answer."
icons: "Prefer Material Icons for consistency."

# ASSUMPTIONS & CONSTRAINTS
assumptions:
  - "Backend (Laravel) exists and provides all necessary APIs and WebSocket endpoints."
  - "Backend handles WebRTC signaling (SDP offer/answer, ICE candidates)."
  - "Backend handles file upload/download for media messages."
constraints:
  - "Generate FRONTEND CODE ONLY. No backend code."
  - "Focus on UI, state management, and API/WebSocket integration logic."
  - "Assume models (User, Chat, Message, etc.) are already defined. If you need to generate a model, make it simple and use equatable."

# CODING STANDARDS
naming_convention: "lowerCamelCase for variables, UpperCamelCase for classes and enums."
style: "Follow official Flutter style guide. Use const constructors where possible."
error_handling: "Always handle errors in Bloc. Display user-friendly messages via Bloc states."