ChatWave: Calls Module Breakdown
1. MODULE: Calls
Description: This module handles all voice and video call functionality. It is highly dependent on real-time communication via WebRTC and signaling via WebSockets. The UI must be responsive, provide clear feedback, and manage multiple states seamlessly.

A. Screens & Their Purpose
1. Screen: CallsHistoryScreen

Purpose: A log of all incoming, outgoing, and missed calls.

Key Features:

List of call history items.

Filtering by "All", "Missed", or call type (voice/video).

"New Call" FAB which opens a contact picker.

2. Screen: IncomingCallScreen

Purpose: A high-priority, full-screen overlay that appears when the user is receiving a call. Must be accessible from a locked phone (requires native integration, but UI is built in Flutter).

Key Features:

caller's avatar, name, and call type (Voice/Video).

Answer (Green) and Decline (Red) buttons.

For video calls, a small PiP of the local video preview.

3. Screen: OutgoingCallScreen / CallingScreen

Purpose: The screen shown to the user who is initiating a call. Displays while the call is ringing and connecting.

Key Features:

Recipient's avatar, name, and call status ("Ringing...", "Connecting...").

A large button to Cancel the call.

4. Screen: ActiveCallScreen

Purpose: The main interface during an ongoing call. Its layout and controls differ significantly between voice and video modes.

Key Features:

Video Call: Remote video feed (fullscreen), Local video PiP, Call controls (mute, video off, etc.).

Voice Call: Large caller avatar, Call duration, Call controls (speaker, mute, etc.).

Group Call: Grid view of multiple participant videos.

B. Widgets & UI Components (Atomic Level)
1. Widget: CallHistoryItem

Location: CallsHistoryScreen

Behavior:

Displays: caller's avatar, name, call type icon (phone/video), timestamp, call direction icon (incoming/outgoing/missed).

Tapping could show a quick action menu (Call back, Message).

Color coding: Missed calls are often red.

2. Widget: CallControlsBottomBar

Location: ActiveCallScreen

Behavior: A persistent bar of icon buttons for call actions. Buttons have visual states (on/off).

Standard Buttons:

Mute: Toggles microphone. Shows a visual indicator when active.

Speaker: Toggles speakerphone. Shows indicator.

End Call: Large, central, red button to terminate the call.

Video-Specific Buttons:

Video On/Off: Toggles the local user's video feed.

Switch Camera: Toggles between front and rear cameras.

Optional Buttons:

More Options: Expands a menu for other actions (e.g., "Message", "Add Participant").

3. Widget: CallInfoTopBar

Location: ActiveCallScreen, OutgoingCallScreen

Behavior: A semi-transparent bar at the top of the call screen.

Displays: Call status ("Ringing", "Connected"), Call duration timer (once connected), Caller name, Network quality indicator.

4. Widget: VideoLayout

Location: ActiveCallScreen (for video calls)

Behavior:

Primary: RTCVideoView(remoteRenderer) stretched to full screen.

Picture-in-Picture (PiP): A small, draggable Container containing RTCVideoView(localRenderer). This shows the user their own video feed.

Group Call Layout: If more than 2 participants, switches to a GridView or custom layout showing all remote video feeds.

5. Widget: VoiceLayout

Location: ActiveCallScreen (for voice calls)

Behavior:

Displays a large CircleAvatar of the caller in the center of the screen.

The CallInfoTopBar and CallControlsBottomBar are still present.

C. State Management & Blocs
1. Bloc: CallBloc

Responsibility: The central brain for the entire call lifecycle. It manages call state, interacts with WebRTC, and handles signaling via the repository.

States (The Call Lifecycle):

CallInitial() - No active call.

CallOutgoing(Call call) - User is dialing. UI: OutgoingCallScreen.

CallIncoming(Call call) - User is receiving a call. UI: IncomingCallScreen.

CallConnected(Call call, RTCVideoRenderer localRenderer, RTCVideoRenderer remoteRenderer) - Call is active. UI: ActiveCallScreen. Contains the WebRTC renderers.

CallEnded(Call call, CallEndReason reason) - Final state. UI: Displays "Call Ended" for 2 seconds then navigates back. reason can be localHungUp, remoteHungUp, networkError, etc.

CallFailure(String message) - Something went wrong.

Events (User & Signaling Actions):

CallInitiated({required String recipientId, required bool isVideo}) - User taps call button.

CallIncomingReceived(Map<String, dynamic> signalingData) - From WebSocket.

CallAnswered() - User taps "Answer".

CallHungUp() - User taps "End Call".

CallRejected() - User taps "Decline".

CallToggleMute()

CallToggleSpeaker()

CallToggleVideo()

CallSwitchCamera()

D. Data Models
dart
enum CallType { voice, video }
enum CallStatus { dialing, ringing, connecting, connected, ended }
enum CallDirection { incoming, outgoing }

class Call with EquatableMixin {
  final String id;
  final User caller;
  final User receiver;
  final CallType type;
  final CallStatus status;
  final CallDirection direction;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration? duration; // Calculated from start & end time

  @override
  List<Object?> get props => [id, caller, receiver, type, status, direction, startTime, endTime];
}

class CallEndReason {
  final String message;
  // Could be an enum for internal handling
}
E. User Flow & Behavior (The Complete Call Lifecycle)
1. Initiating an Outgoing Call:

User taps the call button in a chat header or the Calls History FAB.

UI dispatches: CallBloc.add(CallInitiated(recipientId: '123', isVideo: true)).

CallBloc:

Creates a new Call object with status: dialing, direction: outgoing.

Emits CallOutgoing(call) to show the OutgoingCallScreen.

Signaling: Calls CallRepository.initiateCall(call). This repository method sends a signaling message via the WebSocket to the Laravel backend, which then routes it to the recipient.

2. Receiving an Incoming Call:

A signaling message is received from the Laravel backend via the WebSocket connection.

The CallRepository listens to the WebSocket stream. Upon receiving an "incoming-call" event, it:

Converts the data into a Call object (direction: incoming).

Dispatches CallIncomingReceived(callData) to the CallBloc.

CallBloc emits CallIncoming(call), which triggers the system to show the full-screen IncomingCallScreen.

3. Answering a Call:

User taps the Answer button on the IncomingCallScreen.

UI dispatches: CallBloc.add(CallAnswered()).

CallBloc:

WebRTC Setup: Uses flutter_webrtc to create an answer SDP, gather ICE candidates, and configure the local and remote media streams.

Signaling: Sends the answer SDP and ICE candidates back to the caller via the CallRepository and WebSocket.

Emits CallConnected(call, localRenderer, remoteRenderer) to switch to the ActiveCallScreen.

4. During an Active Call (UI Updates):

The ActiveCallScreen is built with the provided RTCVideoRenderer objects for the local and remote video.

The CallInfoTopBar starts a timer based on startTime.

User taps Mute: CallBloc.add(CallToggleMute()) -> Bloc toggles the audio track enabled state and updates the UI state for the button.

User taps Switch Camera: CallBloc.add(CallSwitchCamera()) -> Bloc uses the flutter_webrtc API to switch the camera.

5. Ending a Call:

User taps the End Call button.

UI dispatches: CallBloc.add(CallHungUp()).

CallBloc:

Signaling: Sends a "hang-up" signal to the other party via the WebSocket.

Cleanup: Closes the WebRTC peer connection and disposes of the video renderers.

Final State: Emits CallEnded(call, CallEndReason.localHungUp).

The UI shows a "Call Ended" dialog for a few seconds, then automatically pops back to the previous screen.