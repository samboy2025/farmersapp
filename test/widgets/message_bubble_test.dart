import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app2/screens/chat/widgets/message_bubble.dart';
import 'package:chat_app2/models/message.dart';
import 'package:chat_app2/models/user.dart';

void main() {
  group('MessageBubble Widget Tests', () {
    late Message testMessage;
    late User testUser;

    setUp(() {
      testUser = User(
        id: 'current_user',
        phoneNumber: '+1234567890',
        name: 'John Doe',
        lastSeen: DateTime.now(),
      );

      testMessage = Message(
        id: 'msg_1',
        chatId: 'chat_123',
        sender: testUser,
        type: MessageType.text,
        content: 'Hello there!',
        timestamp: DateTime.now(),
      );
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: Scaffold(
          body: MessageBubble(
            message: testMessage,
            isLastMessage: false,
          ),
        ),
      );
    }

    testWidgets('should render text message correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Hello there!'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should render sender avatar', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircleAvatar), findsOneWidget);
      expect(find.text('J'), findsOneWidget); // First letter of name
    });

    testWidgets('should render message timestamp', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should show some form of timestamp
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('should render image message correctly', (WidgetTester tester) async {
      final imageMessage = Message(
        id: 'msg_2',
        chatId: 'chat_123',
        sender: testUser,
        type: MessageType.image,
        content: 'Image caption',
        mediaUrl: 'https://example.com/image.jpg',
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: imageMessage,
              isLastMessage: false,
            ),
          ),
        ),
      );

      expect(find.text('Image caption'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('should render video message correctly', (WidgetTester tester) async {
      final videoMessage = Message(
        id: 'msg_3',
        chatId: 'chat_123',
        sender: testUser,
        type: MessageType.video,
        content: 'Video caption',
        mediaUrl: 'https://example.com/video.mp4',
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: videoMessage,
              isLastMessage: false,
            ),
          ),
        ),
      );

      expect(find.text('Video caption'), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should render file message correctly', (WidgetTester tester) async {
      final fileMessage = Message(
        id: 'msg_4',
        chatId: 'chat_123',
        sender: testUser,
        type: MessageType.file,
        content: 'File message',
        fileName: 'document.pdf',
        fileSize: 1024,
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: fileMessage,
              isLastMessage: false,
            ),
          ),
        ),
      );

      expect(find.text('document.pdf'), findsOneWidget);
      expect(find.byIcon(Icons.attach_file), findsOneWidget);
    });

    testWidgets('should render voice message correctly', (WidgetTester tester) async {
      final voiceMessage = Message(
        id: 'msg_5',
        chatId: 'chat_123',
        sender: testUser,
        type: MessageType.voiceMessage,
        content: 'Voice message',
        voiceDuration: Duration(seconds: 30),
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: voiceMessage,
              isLastMessage: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.text('30s'), findsOneWidget);
    });

    testWidgets('should render location message correctly', (WidgetTester tester) async {
      final locationMessage = Message(
        id: 'msg_6',
        chatId: 'chat_123',
        sender: testUser,
        type: MessageType.location,
        content: 'My location',
        latitude: 40.7128,
        longitude: -74.0060,
        locationName: 'New York',
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: locationMessage,
              isLastMessage: false,
            ),
          ),
        ),
      );

      expect(find.text('My location'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('should render contact message correctly', (WidgetTester tester) async {
      final contactMessage = Message(
        id: 'msg_7',
        chatId: 'chat_123',
        sender: testUser,
        type: MessageType.contact,
        content: 'Contact Name',
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: contactMessage,
              isLastMessage: false,
            ),
          ),
        ),
      );

      expect(find.text('Contact Name'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('should render reactions when present', (WidgetTester tester) async {
      final messageWithReactions = Message(
        id: 'msg_8',
        chatId: 'chat_123',
        sender: testUser,
        type: MessageType.text,
        content: 'Message with reactions',
        timestamp: DateTime.now(),
        reactions: {'👍': ['user1', 'user2'], '❤️': ['user3']},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: messageWithReactions,
              isLastMessage: false,
            ),
          ),
        ),
      );

      expect(find.text('👍'), findsOneWidget);
      expect(find.text('❤️'), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // Reaction count
    });

    testWidgets('should show group sender name for group chats', (WidgetTester tester) async {
      final groupMessage = Message(
        id: 'msg_9',
        chatId: 'group_chat_123',
        sender: testUser,
        type: MessageType.text,
        content: 'Group message',
        timestamp: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: groupMessage,
              isLastMessage: false,
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('should handle long press for message options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Long press on the message bubble
      await tester.longPress(find.byType(GestureDetector));
      await tester.pump();

      // Should show popup menu
      expect(find.byType(PopupMenuButton), findsOneWidget);
    });
  });
}
