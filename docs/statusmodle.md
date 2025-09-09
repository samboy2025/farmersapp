ChatWave: Status Module Breakdown
1. MODULE: Status
Description: This module allows users to post image or video updates that disappear after 24 hours. Other users can view these updates in a sequential, story-like interface. It requires efficient media uploading, downloading, and playback.

A. Screens & Their Purpose
1. Screen: StatusListScreen

Purpose: The main entry point. Displays a list of contacts who have posted status updates, prioritized by unviewed updates and recency.

Key Features:

Section for "My Status" at the top.

Section for "Recent Updates" (contacts with new statuses).

Section for "Viewed Updates" (contacts with statuses you've already seen).

2. Screen: StatusViewerScreen

Purpose: A full-screen, immersive experience for viewing a user's sequence of status updates.

Key Features:

Horizontal pagination between a user's multiple statuses.

Vertical pagination (swipe up/down) to move between different users' statuses.

Progress indicator bars at the top for each status in the sequence.

Auto-advancement of statuses after a set duration (e.g., 5 seconds).

Tap-to-pause playback.

3. Screen: StatusComposerScreen

Purpose: Allows the user to create a new status update from their camera or gallery.

Key Features:

Camera preview with a capture button.

Or, a gallery picker view.

Basic editing tools: ability to add text captions or drawings over the image/video.

B. Widgets & UI Components (Atomic Level)
1. Widget: StatusListItem

Location: StatusListScreen

Behavior:

Displays: contact's avatar, name, time of status post, and a circular progress border indicating it's new.

A tiny circular icon indicates the type (image or video).

Tapping navigates to the StatusViewerScreen, starting with that user's updates.

2. Widget: MyStatusCard

Location: StatusListScreen (at the top of the list).

Behavior:

Displays the user's own avatar with a "+" add button.

If the user has an active status, it shows a preview and "My Status" text.

Tapping when a status exists views your own status. Tapping the "+" button opens the StatusComposerScreen.

3. Widget: StatusProgressIndicator

Location: StatusViewerScreen (at the very top).

Behavior:

A row of small, horizontal progress bars. Each bar represents one status in the current user's sequence.

The active bar fills up linearly over the set duration (e.g., 5 seconds), providing a visual timer.

Tapping the left side goes back a status; tapping the right side goes forward.

4. Widget: StatusViewerControls

Location: StatusViewerScreen (semi-transparent overlay on top of the media).

Behavior:

Profile Info: Displays the contact's name and the time since posting (e.g., "5m ago").

Menu Button ("..."): Opens a bottom sheet with options like "Mute", "Reply", "Forward", "Delete".

Reply Input Field: A text field that appears at the bottom, allowing the user to send a direct message in response to the status. This message is sent to a dedicated "Status Replies" chat or a regular chat with the user.

5. Widget: StatusCaptionOverlay

Location: StatusViewerScreen and StatusComposerScreen.

Behavior:

Displays text or drawings that the user added on top of their image/video.

Positioned based on where the user placed it during composition.

C. State Management & Blocs
1. Bloc: StatusBloc

Responsibility: Managing the list of status updates from all contacts and the user's own status.

States:

StatusLoadInProgress()

StatusLoadSuccess(Map<User, List<Status>> statusUpdates) // Groups statuses by user

StatusUploadInProgress()

StatusUploadSuccess()

StatusOperationFailure(String error)

Events:

StatusFetched() // Fetches the list of all contacts' statuses from the API

StatusViewed({required String statusId}) // Marks a specific status as viewed

StatusUploaded(File mediaFile, String? caption) // Initiates the upload process

StatusDeleted(Status status)

2. Bloc: StatusViewerBloc

Responsibility: Managing the state and playback for the specific statuses being viewed in the StatusViewerScreen. This is a short-lived Bloc created when the viewer is opened.

States:

StatusViewerInitial()

StatusViewerReady(Status currentStatus, int currentIndex, int totalCount)

StatusViewerPlaying(Duration position) // For video statuses

StatusViewerPaused()

StatusViewerFinished() // Moves to the next status automatically

Events:

StatusViewerStarted(List<Status> statuses, int startIndex)

StatusViewerPlay()

StatusViewerPause()

StatusViewerNext()

StatusViewerPrevious()

StatusViewerSeek(Duration position)

StatusViewerExited()

D. Data Models
dart
class Status with EquatableMixin {
  final String id;
  final User user;
  final String mediaUrl;
  final StatusType type; // image, video
  final String? caption;
  final DateTime createdAt;
  final DateTime expiresAt; // createdAt + 24 hours
  final bool isViewed; // Has the current user seen this?

  // Helper getter
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [id, user, mediaUrl, type, caption, createdAt, expiresAt, isViewed];
}
E. User Flow & Behavior
1. Viewing Statuses:

User opens the StatusListScreen. The StatusBloc fetches the list of updates via the StatusRepository.

The UI is built based on StatusLoadSuccess, grouping statuses by user and separating viewed/unviewed.

User taps on a StatusListItem for a contact with new updates.

The StatusViewerScreen is pushed. It creates a StatusViewerBloc and adds StatusViewerStarted([listOfStatuses], 0).

The viewer loads the first status. If it's a video, it prepares the video player and auto-plays. If it's an image, it just displays it.

The StatusProgressIndicator starts animating. When it completes, the StatusViewerBloc automatically handles moving to the next status (StatusViewerNext).

When a status is displayed, the bloc automatically calls the repository to mark it as viewed on the backend, which updates the isViewed flag.

2. Creating a Status:

User taps the "+" on their MyStatusCard.

The app requests camera/gallery permissions. The StatusComposerScreen opens.

User captures a photo/video or selects one from their gallery.

(Optional) They add a text caption or drawing.

User taps "Send".

The UI dispatches StatusUploaded(mediaFile, caption) to the StatusBloc.

The StatusBloc:

Emits StatusUploadInProgress() (shows a loading indicator).

Calls StatusRepository.uploadStatus(mediaFile, caption). This repository:

Uploads the media file to the Laravel backend (multipart request).

Then, calls a separate API endpoint to create the status entry in the DB with the returned media URL.

On success, emits StatusUploadSuccess(), triggering a refresh of the status list.

On failure, emits StatusOperationFailure(error).

3. Ephemeral Nature (Backend-Driven):

The Laravel backend is responsible for automatically deleting status records and their associated media files after expiresAt (24 hours).

The Flutter app should filter out any expired statuses it receives from the API using the isExpired getter to avoid showing them.

4. Replying to a Status:

While viewing a status, the user taps the reply input field and types a message.

On send, this does not create a new status. Instead, it triggers a call to ChatRepository.sendMessage(...) to send a text message to a one-on-one chat with the status poster. The message could be prefixed with a context, e.g., "Re: Your Status".

5. Advanced Status Features:
   - Status Duration Options: 1 hour, 12 hours, 24 hours, 48 hours
   - Status Scheduling: Set future posting times
   - Status Templates: Save and reuse status layouts
   - Collaborative Statuses: Co-create statuses with contacts
   - Status Challenges: Participate in themed status challenges

J. Implementation Guidelines & Questions

1. Status Duration Flexibility:
   - Question: Should users be able to choose different expiration times?
   - Recommendation: Start with 24 hours fixed, add duration options in v2.0
   - Implementation: Store duration preference in user settings

2. Group Status Support:
   - Question: Can statuses be posted to group chats?
   - Recommendation: Individual contacts only for MVP, group support in future
   - Implementation: Extend Status model with audience field

3. Media Quality Standards:
   - Question: What are the specific quality requirements?
   - Recommendation: Implement adaptive quality based on network conditions
   - Implementation: Use Flutter's image/video compression libraries

4. Backend API Integration:
   - Question: Are Laravel endpoints already defined?
   - Recommendation: Define API contracts before Flutter implementation
   - Implementation: Create OpenAPI/Swagger documentation

5. Performance Benchmarks:
   - Question: What are acceptable load times and memory usage?
   - Recommendation: Target <2s load time, <100MB memory usage
   - Implementation: Use Flutter performance profiling tools

6. Testing Strategy:
   - Unit Tests: Test all Bloc logic and data models
   - Widget Tests: Test UI components and interactions
   - Integration Tests: Test complete user flows
   - Performance Tests: Test memory usage and load times

7. Deployment Considerations:
   - Platform Support: iOS 12+, Android API 21+
   - App Store Requirements: Privacy policy, content guidelines
   - Backend Scaling: Handle media storage and CDN distribution
   - Monitoring: Track crashes, performance metrics, user analytics