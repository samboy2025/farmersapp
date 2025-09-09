Product Requirements Document (PRD): WhatsApp Clone (Flutter Frontend) - V2.0
Version: 2.0
Date: October 26, 2023
Author: [Your Name/Team Name]
Status: Draft

1. Introduction & Vision (Updated)
This document details the requirements for the frontend of "ChatWave," a comprehensive WhatsApp-like application built with Flutter. The application will support rich messaging (text, images, video, files, contacts, location, voice notes), profile management, and high-quality voice and video calls. This PRD defines the UI, UX, and frontend logic, assuming a Laravel backend will be developed separately to provide all necessary APIs and WebSocket connections.

2. User Personas (Updated)
Alex (The Frequent Caller): Needs reliable voice/video calls and clear controls.

Bella (The Group Organizer): Shares media and location frequently in groups. Uses voice notes for quick updates.

Charlie (The Privacy-Conscious User): Values clear encryption indicators and control over shared data.

Diana (The Power Communicator): Uses every feature—sends documents, shares contacts, and uses emojis to express tone. Meticulously manages her profile.

3. Functional Requirements (Expanded)
3.1. Core Messaging & Authentication
Authentication Flow: Splash Screen -> Login/Registration (Phone number input -> OTP verification screen).

Chats List Screen: List of conversations, last message preview, unread count, timestamp. Pin chats functionality.

Contacts Screen: List of contacts from the user's phonebook who are on the app.

3.2. Rich Individual & Group Chat Screen
This is the central hub for communication. The UI must be dynamic and handle multiple message types.

Message Bubbles: Distinct visual styles for sent vs. received messages. Display of sender name in groups.

Message Status Indicators: (Clock icon -> Single tick -> Double tick -> Blue double ticks) for sent, delivered, and read receipts.

Message Types & UI:

Text: Displayed with emoji support (using a package like emoji_picker_flutter).

Image/Video: Displayed as a thumbnail in the chat. Tapping opens a full-screen media viewer with options to share/save.

File/PDF: Displayed with a file icon, filename, and file size. Tapping initiates a download (via backend API) and opens the file with a platform-specific viewer.

Contact (vCard): Displayed as a contact card with the shared name and phone number. Tapping should offer to add to the device's contacts or call/message that number.

Location: Displayed as a static map snapshot (e.g., using Google Static Maps API) with a pin. Tapping opens the native maps application at that coordinates.

Voice Message:

UI: A waveform visualizer (can be a static bar initially) with a play/pause button and a duration timer.

Recording: Long-press on the microphone icon in the input field activates recording. A slide-to-cancel gesture is required. Releasing sends the audio file.

Input Toolbar:

Text field.

Emoji picker button.

Attachment button (opens a bottom sheet with icons for: Gallery, Camera, Document, Contact, Location).

Voice note microphone button (with hold-to-record functionality).

Send button.

3.3. User Profile Management
Profile Screen: Accessed from a drawer navigation menu or settings.

View: Displays user's current profile picture, name, "About" bio, and phone number.

Edit: Tapping on the profile picture opens a dialog to choose a new image from gallery or camera. Tapping on name or "About" opens a text input dialog to edit the information.

Action: All changes are sent to the backend via API calls. The UI must update optimistically.

3.4. Voice & Video Calling Module
(As defined in the previous PRD, but now integrated with the new profile and chat context)

4. Technical Architecture & State Management
4.1. State Management Selection: Bloc (Business Logic Component)
Justification: For a complex app like this with multiple real-time features and API interactions, Bloc is an excellent choice. It separates business logic from presentation perfectly, making the code highly predictable, testable, and maintainable. It handles the asynchronous nature of API calls and WebSocket streams elegantly.

Key BLoCs We Will Need:

AuthBloc: Handles login, OTP verification, and logout states.

ChatBloc: Manages the list of chats, fetching messages for a specific chat, and sending new messages (of all types).

MessageBloc (optional): Could be merged with ChatBloc or handle real-time incoming messages via a stream.

ContactBloc: Fetches and filters the user's contact list.

ProfileBloc: Handles fetching and updating user profile information.

CallBloc: The most complex. Will handle call states: CallInitial, CallDialing, CallIncoming, CallConnected, CallEnded. It will interact with the flutter_webrtc plugin based on signaling from the backend.

4.2. Data Flow
UI (View): The Flutter widgets (e.g., ChatScreen).

Bloc (Controller/Logic): Listens for Events (e.g., SendTextMessage) and maps them to States (e.g., MessageSending, MessageSent, MessageError). It talks to the...

Repository Layer (Data Gateway): A layer that abstracts the data sources. A ChatRepository will have methods like sendMessage(...). It decides whether to get data from the...

Data Sources: REST API (Laravel) for most data (chats, profiles) and WebSocket for real-time messages and call signaling. Local Database (Optional - Hive/Isar) for offline caching of messages and contacts.

4.3. Key External Packages (Pub.dev)
flutter_bloc: For implementing the BLoC pattern.

equatable: To simplify value-based equality for Bloc States and Events.

dio or http: For making HTTP requests to the Laravel API.

web_socket_channel: For managing the WebSocket connection to the Laravel backend.

flutter_webrtc: Critical. For handling voice and video call media streams.

image_picker: For selecting images and videos from the gallery or camera.

file_picker: For picking documents, and files from device storage.

location: For fetching the current device's location.

permission_handler: For requesting camera, microphone, contacts, and location permissions.

cached_network_image: For efficient loading and caching of profile and image messages.

emoji_picker_flutter: For a rich emoji selection interface.

record: For high-quality audio recording for voice messages.

5. Non-Functional Requirements (NFRs) - Enhanced
Performance: Smooth 60 FPS scrolling through media-heavy chats. Efficient memory management during long video calls.

Offline Capability (Basic): The UI should not crash if offline. Messages can be queued (using Bloc states like MessageSending) and sent when connectivity is restored. (Full offline sync with a local DB is a future consideration).

Security: All API calls must be made over HTTPS. Sensitive data in the UI (like passwords) must be obscured.

Error Handling: Robust error handling throughout. Users must be informed of failures (e.g., "Message failed to send. Tap to retry.") via Bloc Error states.

Maintainability: Strict adherence to the Bloc pattern. Consistent coding conventions. High test coverage for all Blocs.

6. UI/UX Wireframes (Descriptive - Additions)
Attachment Bottom Sheet: A modal sheet that slides up from the bottom with a grid of icons: Photo Library, Camera, Document, Contact, Location.

Media Full-Screen Viewer: A page with the image/video displayed full-screen, with a semi-transparent app bar containing a back button and a download/share button.

Voice Message Player: A custom widget within the message bubble with a play button, a progress bar that fills as the audio plays, and the duration displayed.

Profile Edit Screen: A simple form with a clickable avatar, a text field for the name, and a text field for the "About" bio.

7. Success Metrics
Feature Adoption: Percentage of users sending non-text messages (voice, images, files).

Profile Completion: Percentage of users who have set a profile picture and bio.

Call Reliability: Ratio of completed calls to dropped calls.