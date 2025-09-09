# ChatWave Complete Call System

## Overview

This document describes the complete call system implementation for the ChatWave Flutter app. The system provides comprehensive voice and video calling functionality with WebRTC integration, real-time signaling, and seamless integration across the app.

## Architecture

### Core Components

1. **Call Models** (`lib/models/call.dart`)
   - `Call` class with comprehensive call state management
   - `CallType` enum (voice/video)
   - `CallStatus` enum (dialing, incoming, connecting, connected, ended, etc.)

2. **Call Repository** (`lib/repositories/call_repository.dart`)
   - WebRTC peer connection management
   - WebSocket signaling for call establishment
   - Media stream handling (audio/video)
   - ICE candidate management

3. **Call Bloc** (`lib/blocs/call/call_bloc.dart`)
   - State management for all call operations
   - Event handling for call actions
   - Integration with call repository
   - Real-time call state updates

4. **Call Service** (`lib/services/call_service.dart`)
   - High-level call operations
   - Call state management
   - Integration with user management
   - Call history management

5. **Call Integration Service** (`lib/services/call_integration_service.dart`)
   - App-wide call integration
   - Chat system integration
   - User interface coordination
   - Error handling and user feedback

6. **Call UI Components** (`lib/widgets/call_buttons.dart`)
   - Reusable call buttons
   - Call status indicators
   - Call history items
   - Chat header integration

7. **Call Screens** (`lib/screens/call/`)
   - `CallScreen` - Main call interface
   - `CallHistoryScreen` - Call history and management

## Features

### Voice Calls
- High-quality audio calls
- Mute/unmute functionality
- Speaker mode toggle
- Call duration tracking
- Call quality indicators

### Video Calls
- HD video streaming
- Camera switching (front/back)
- Video on/off toggle
- Picture-in-Picture local video
- Video quality optimization

### Call Management
- Incoming call handling
- Call rejection
- Call forwarding
- Call history tracking
- Missed call notifications

### Integration Features
- Seamless chat integration
- User status awareness
- Busy user detection
- Call-in-progress indicators
- Cross-screen call state

## Implementation Details

### WebRTC Configuration

```dart
final configuration = {
  'iceServers': [
    {'urls': 'stun:stun.l.google.com:19302'},
    {'urls': 'stun:stun1.l.google.com:19302'},
  ],
};

final constraints = {
  'mandatory': {
    'OfferToReceiveAudio': true,
    'OfferToReceiveVideo': true,
  },
  'optional': [],
};
```

### Call State Machine

1. **Initial** → No active call
2. **Dialing** → Outgoing call initiated
3. **Incoming** → Incoming call received
4. **Connecting** → Call being established
5. **Connected** → Call active
6. **Ended** → Call terminated
7. **Failed** → Call failed to establish

### Signaling Protocol

The system uses WebSocket-based signaling for call establishment:

- **Offer**: Caller sends SDP offer
- **Answer**: Callee responds with SDP answer
- **ICE Candidates**: Both parties exchange network information
- **Hangup**: Call termination signal

## Usage Examples

### Making a Call from Chat

```dart
// In chat screen
final callIntegration = CallIntegrationService();
await callIntegration.makeCallFromChat(context, chat, CallType.voice);
```

### Adding Call Buttons to UI

```dart
// In chat header
CallButtons(
  user: otherUser,
  showLabels: true,
  buttonSize: 36,
)

// Or use the integration service
callIntegration.buildCallButtons(context, chat, showLabels: true)
```

### Handling Call State Changes

```dart
BlocBuilder<CallBloc, CallState>(
  builder: (context, state) {
    if (state is CallConnected) {
      return Text('Call Duration: ${state.duration}');
    }
    return const SizedBox.shrink();
  },
)
```

### Call Status Indicators

```dart
CallStatusIndicator(
  userId: user.id,
  size: 16,
)
```

## Integration Points

### Chat System
- Call buttons in chat headers
- Call status in user lists
- Call history integration
- In-call chat notifications

### User Management
- User availability status
- Busy user detection
- Call permissions
- User preferences

### Navigation
- Call screen routing
- Call history access
- Contact call initiation
- Emergency call handling

## Error Handling

### Common Scenarios
1. **Network Issues**: Automatic retry with exponential backoff
2. **User Busy**: Show appropriate dialog
3. **Call Failed**: Display error message with retry option
4. **Permission Denied**: Guide user to enable permissions
5. **Device Unavailable**: Show device selection dialog

### User Feedback
- Toast messages for quick actions
- Dialog boxes for important decisions
- Progress indicators for long operations
- Error summaries with resolution steps

## Performance Considerations

### WebRTC Optimization
- Adaptive bitrate for video calls
- Audio codec selection based on network
- ICE candidate filtering
- Connection quality monitoring

### Memory Management
- Proper disposal of video renderers
- Stream cleanup on call end
- Bloc state cleanup
- Resource pooling for multiple calls

### Battery Optimization
- Screen wake lock during calls
- Audio focus management
- Background call handling
- Power-aware quality settings

## Testing

### Unit Tests
- Call bloc state transitions
- Repository method validation
- Service integration tests
- Model serialization tests

### Integration Tests
- End-to-end call flow
- WebRTC connection establishment
- Cross-device call testing
- Network condition simulation

### UI Tests
- Call screen interactions
- Button state changes
- Call flow navigation
- Error handling scenarios

## Deployment Considerations

### Platform Support
- **Android**: Full WebRTC support
- **iOS**: WebRTC with native optimizations
- **Web**: Browser WebRTC implementation
- **Desktop**: Platform-specific media handling

### Permissions
- Microphone access
- Camera access
- Network access
- Background processing

### Dependencies
```yaml
dependencies:
  flutter_webrtc: ^1.1.0
  web_socket_channel: ^3.0.3
  flutter_bloc: ^7.3.3
  equatable: ^2.0.5
```

## Future Enhancements

### Planned Features
1. **Group Calls**: Multi-party video conferencing
2. **Call Recording**: Audio/video call recording
3. **Call Analytics**: Call quality metrics and reporting
4. **Advanced Controls**: Noise suppression, echo cancellation
5. **Call Scheduling**: Future call scheduling
6. **Call Transfers**: Call forwarding and transfer

### Technical Improvements
1. **WebRTC 1.0**: Latest WebRTC standards
2. **AI Enhancement**: Background blur, virtual backgrounds
3. **Network Optimization**: Better ICE handling
4. **Security**: End-to-end encryption
5. **Scalability**: Multi-server architecture

## Troubleshooting

### Common Issues

1. **Call Not Connecting**
   - Check network connectivity
   - Verify WebRTC permissions
   - Check firewall settings
   - Validate signaling server

2. **Poor Call Quality**
   - Monitor network conditions
   - Adjust video resolution
   - Check device performance
   - Verify bandwidth availability

3. **Audio/Video Issues**
   - Check device permissions
   - Verify device selection
   - Test with different devices
   - Check codec compatibility

### Debug Information

Enable debug logging for troubleshooting:

```dart
// In development
if (kDebugMode) {
  print('Call State: $state');
  print('WebRTC Connection: ${peerConnection?.connectionState}');
  print('Media Streams: ${localStream?.id} / ${remoteStream?.id}');
}
```

## Support

For technical support or questions about the call system:

1. Check the troubleshooting section
2. Review the error logs
3. Test with different network conditions
4. Verify device compatibility
5. Contact the development team

## License

This call system is part of the ChatWave application and follows the same licensing terms.

---

**Note**: This system is designed for production use but may require additional testing and optimization for specific deployment environments.
