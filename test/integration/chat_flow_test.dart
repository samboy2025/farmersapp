import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app2/screens/chat/chat_screen.dart';
import 'package:chat_app2/blocs/chat/message_bloc.dart';
import 'package:chat_app2/models/chat.dart';
import 'package:chat_app2/models/user.dart';
import 'package:chat_app2/models/message.dart';

void main() {
  group('Chat Flow Integration Tests', () {
    late MessageBloc messageBloc;
    late Chat testChat;
    late User testUser;

    setUp(() {
      messageBloc = MessageBloc();
      testUser = User(
        id: 'current_user',
        phoneNumber: '+1234567890',
        name: 'John Doe',
        lastSeen: DateTime.now(),
      );
      testChat = Chat(
        id: 'chat_123',
        name: 'Test Chat',
        participants: [testUser],
        lastActivity: DateTime.now(),
        createdAt: DateTime.now(),
      );
    });

    tearDown(() {
      messageBloc.close();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<MessageBloc>.value(
          value: messageBloc,
          child: ChatScreen(chat: testChat),
        ),
      );
    }

    testWidgets('should display chat screen with initial state', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should show chat screen
      expect(find.byType(ChatScreen), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget); // Message input
    });

    testWidgets('should send message and display it', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter message
      await tester.enterText(find.byType(TextField), 'Hello World');
      await tester.pump();

      // Tap send button
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Message should be displayed
      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('should toggle search mode', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially no search bar
      expect(find.text('Search in chat...'), findsNothing);

      // Open chat options
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Tap search option
      await tester.tap(find.text('Search in Chat'));
      await tester.pumpAndSettle();

      // Search bar should appear
      expect(find.text('Search in chat...'), findsOneWidget);
    });

    testWidgets('should perform search and show results', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // First send a message
      await tester.enterText(find.byType(TextField), 'Searchable message');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Enable search mode
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Search in Chat'));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.text('Search in chat...'), 'Searchable');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Should show search results
      expect(find.text('Searchable message'), findsOneWidget);
    });

    testWidgets('should add reaction to message', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Send a message
      await tester.enterText(find.byType(TextField), 'React to this');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Long press on message to show options
      await tester.longPress(find.text('React to this'));
      await tester.pumpAndSettle();

      // Tap react option
      await tester.tap(find.text('React'));
      await tester.pumpAndSettle();

      // Should show reaction picker
      expect(find.text('Add Reaction'), findsOneWidget);
      expect(find.text('👍'), findsOneWidget);
    });

    testWidgets('should forward message', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Send a message
      await tester.enterText(find.byType(TextField), 'Forward this message');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Long press on message to show options
      await tester.longPress(find.text('Forward this message'));
      await tester.pumpAndSettle();

      // Tap forward option
      await tester.tap(find.text('Forward'));
      await tester.pumpAndSettle();

      // Should show forward screen
      expect(find.text('Forward Message'), findsOneWidget);
    });

    testWidgets('should handle message editing', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Send a message
      await tester.enterText(find.byType(TextField), 'Original message');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Long press on message to show options
      await tester.longPress(find.text('Original message'));
      await tester.pumpAndSettle();

      // Should show edit option (if implemented)
      // This test verifies the message options menu appears
      expect(find.byType(PopupMenuButton), findsOneWidget);
    });

    testWidgets('should handle message deletion', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Send a message
      await tester.enterText(find.byType(TextField), 'Delete this message');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Long press on message to show options
      await tester.longPress(find.text('Delete this message'));
      await tester.pumpAndSettle();

      // Should show delete option (if implemented)
      // This test verifies the message options menu appears
      expect(find.byType(PopupMenuButton), findsOneWidget);
    });

    testWidgets('should handle different message types', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Test text message
      await tester.enterText(find.byType(TextField), 'Text message');
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();
      expect(find.text('Text message'), findsOneWidget);

      // Test file message (if attachment functionality is implemented)
      await tester.tap(find.byIcon(Icons.attach_file));
      await tester.pumpAndSettle();
      
      // Should show attachment options
      expect(find.byType(BottomSheet), findsOneWidget);
    });

    testWidgets('should handle chat options menu', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap avatar to show chat options
      await tester.tap(find.byType(CircleAvatar));
      await tester.pumpAndSettle();

      // Should show chat options
      expect(find.text('View Contact'), findsOneWidget);
      expect(find.text('Search in Chat'), findsOneWidget);
      expect(find.text('Mute Notifications'), findsOneWidget);
    });

    testWidgets('should handle call options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap voice call button
      await tester.tap(find.byIcon(Icons.call));
      await tester.pumpAndSettle();

      // Should show call options
      expect(find.text('Voice Call'), findsOneWidget);
      expect(find.text('Call Test Chat'), findsOneWidget);
    });

    testWidgets('should handle video call options', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap video call button
      await tester.tap(find.byIcon(Icons.videocam));
      await tester.pumpAndSettle();

      // Should show video call options
      expect(find.text('Video Call'), findsOneWidget);
      expect(find.text('Call Test Chat'), findsOneWidget);
    });

    testWidgets('should scroll to bottom when new message is sent', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Send multiple messages to create scrollable content
      for (int i = 0; i < 5; i++) {
        await tester.enterText(find.byType(TextField), 'Message $i');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();
      }

      // Verify messages are displayed
      expect(find.text('Message 0'), findsOneWidget);
      expect(find.text('Message 4'), findsOneWidget);
    });

    testWidgets('should handle empty message input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Try to send empty message
      await tester.tap(find.byIcon(Icons.send));
      await tester.pumpAndSettle();

      // Should not add empty message
      expect(find.text(''), findsNothing);
    });
  });
}
