ChatWave: Chats Module Breakdown
1. MODULE: Chats
Description: This module handles the list of conversations (both individual and group) and the core messaging interface within a single chat. It is the most complex module, supporting multiple message types and real-time interaction.

A. Screens & Their Purpose
1. Screen: ChatsListScreen

Purpose: The home screen. Displays a scrollable list of all conversations, ordered by the most recent activity.

Key Features:

List of chat items.

Search bar (optional but recommended).

Unread message counters.

"New Chat" FAB.

2. Screen: ChatScreen

Purpose: The main messaging interface for a specific conversation (individual or group).

Key Features:

AppBar with recipient info and call buttons.

List of messages ( ListView.builder).

Message input toolbar.

3. Screen: MediaViewerScreen

Purpose: A full-screen viewer for media messages (images, video).

Key Features:

Gesture-based zooming and panning for images.

Playback controls for videos.

Option to save media to the device.

B. Widgets & UI Components (Atomic Level)
1. Widget: ChatListItem

Location: ChatsListScreen

Behavior:

Displays: user/group avatar, name, last message preview, timestamp, unread count.

Tapping navigates to the ChatScreen for that conversation.

Long-press shows a context menu (e.g., Mark as Read, Delete Chat, Mute).

2. Widget: MessageBubble

Location: ChatScreen (within the ListView).

Behavior & Variants:

Generic: Applies padding, background color (green for sent, grey for received), clips edges.

TextBubble: Inherits from generic. Displays text with emoji support. Shows timestamp and read receipts below.

ImageBubble: Inherits from generic. Displays a cached network image thumbnail. Tapping navigates to MediaViewerScreen.

VideoBubble: Similar to ImageBubble, but with a play icon overlay.

FileBubble: Displays a file icon, filename, and file size. Tapping triggers a download via the repository.

ContactBubble: Displays a contact card icon, the shared name, and number. Tapping offers to call/add to contacts.

LocationBubble: Displays a static map image. Tapping opens the coordinates in an external map app.

VoiceMessageBubble: Contains a play/pause button, a progress bar (waveform or linear), and duration. Tapping the button plays/pauses the audio.

3. Widget: ChatAppBar

Location: ChatScreen (as the appBar property).

Behavior:

Displays: recipient's avatar, name, and last seen/online status.

Contains two IconButtons: a voice call and a video call.

Tapping the avatar could show a bottom sheet with quick profile info.

4. Widget: MessageInputToolbar

Location: ChatScreen (fixed at the bottom).

Behavior:

Text Field: Expands vertically for multi-line text. Supports emoji insertion.

Attachment Button: Tapping opens an AttachmentModalBottomSheet.

Voice Record Button: Long-press to record. Visual feedback (e.g., a record waveform) appears on press. Slide to cancel gesture dismisses the recording UI without sending. Releasing sends.

Send Button: Appears when text is entered. Sends the text message.

5. Widget: AttachmentModalBottomSheet

Behavior: A modal that slides up with a grid of options.

Options:

Gallery: Launches image_picker to pick an image/video.

Camera: Launches image_picker to take a photo/video.

Document: Launches file_picker to select any file (pdf, doc, etc.).

Contact: (Future) Opens device contacts to share one.

Location: Fetches current location via the location package and sends it.

6. Widget: AudioRecorderOverlay

Behavior: A semi-transparent overlay that appears when the voice record button is long-pressed.

UI: A microphone icon, a timer, and a "Slide to cancel" text. Visually feedback for recording volume.

C. State Management & Blocs
1. Bloc: ChatBloc

Responsibility: Managing the list of chats.

States:

ChatsLoadInProgress()

ChatsLoadSuccess(List<Chat> chats)

ChatsLoadFailure(String error)

Events:

ChatsFetched() (Called on app start/login)

ChatDeleted(Chat chat)

ChatsUpdatedViaWebSocket(ChatEvent event) (For real-time updates)

2. Bloc: MessageBloc

Responsibility: Managing messages for a specific chat and handling sending/receiving.

States:

MessagesLoadInProgress()

MessagesLoadSuccess(List<Message> messages)

MessageSendInProgress(Message message) (Optimistic UI - show message greyed out)

MessageSendSuccess(Message message) (Update message to delivered/sent state)

MessageSendFailure(Message message, String error) (Show error icon, tap to retry)

Events:

MessagesFetched(String chatId)

MessageSent(Message message) (e.g., TextMessage, ImageMessage)

MessageReceived(Message message) (From WebSocket stream)

MessageRetried(Message failedMessage)

D. Data Models (Examples)
dart
// Base Class
abstract class Message with EquatableMixin {
  final String id;
  final String chatId;
  final User sender;
  final DateTime timestamp;
  final MessageStatus status; // sent, delivered, read
  final MessageType type; // text, image, voice, etc.

  @override
  List<Object?> get props => [id, chatId, sender, timestamp, status, type];
}

// Concrete Classes
class TextMessage extends Message {
  final String text;
  TextMessage({...required fields, required this.text}) : super(...);
  // props override includes 'text'
}

class ImageMessage extends Message {
  final String imageUrl;
  final String? thumbnailUrl;
  ImageMessage({...required fields, required this.imageUrl, this.thumbnailUrl}) : super(...);
  // props override includes 'imageUrl', 'thumbnailUrl'
}

class VoiceMessage extends Message {
  final String audioUrl;
  final Duration duration;
  VoiceMessage({...required fields, required this.audioUrl, required this.duration}) : super(...);
  // props override includes 'audioUrl', 'duration'
}
// ... Similar classes for VideoMessage, FileMessage, etc.
E. User Flow & Behavior
Opening a Chat:

User taps ChatListItem on ChatsListScreen.

ChatScreen is pushed with BlocProvider.of<MessageBloc>(context).add(MessagesFetched(chatId)).

MessageBloc fetches message history from the MessageRepository (which calls the Laravel API).

UI shows a loading spinner until MessagesLoadSuccess is emitted, then displays the list.

Sending a Text Message:

User types text and hits send.

MessageInputToolbar creates a TextMessage object with a temporary ID and status: sent.

MessageBloc.add(MessageSent(textMessage)).

Bloc immediately emits MessageSendInProgress(textMessage) to show the message optimistically.

Bloc calls MessageRepository.sendMessage(textMessage).

On API success, Bloc emits MessageSendSuccess(newMessageWithRealId) to update the status.

On Failure, emits MessageSendFailure(textMessage, error).

Sending an Image:

User taps attachment -> Gallery -> selects image.

UI shows a loading indicator on the ImageBubble before it's even sent.

MessageBloc creates an ImageMessage and emits MessageSendInProgress.

The MessageRepository first uploads the image file to the Laravel backend (via multipart request).

Once uploaded, the backend returns a URL, which is then used to "send" the message via another API call.

Receiving a Message (Real-Time):

A WebSocket listener (set up in the repository) receives a new message event.

The repository converts this event into a Dart Message object.

The repository adds this message to the appropriate MessageBloc's stream (if the chat is open) OR notifies the ChatBloc to update the last message preview and unread count.

Playing a Voice Message:

The VoiceMessageBubble displays a play button and the duration.

Tapping the button triggers a function (via a Bloc or a custom player service) to play the audio from the audioUrl.

The bubble's UI changes: play button becomes pause, a progress bar advances.