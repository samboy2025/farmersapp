import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app2/screens/chat/widgets/chat_search_bar.dart';
import 'package:chat_app2/blocs/chat/message_bloc.dart';

void main() {
  group('ChatSearchBar Widget Tests', () {
    late MessageBloc messageBloc;

    setUp(() {
      messageBloc = MessageBloc();
    });

    tearDown(() {
      messageBloc.close();
    });

    Widget createTestWidget() {
      return MaterialApp(
        home: BlocProvider<MessageBloc>.value(
          value: messageBloc,
          child: Scaffold(
            body: ChatSearchBar(
              chatId: 'test_chat_id',
              onClose: () {},
            ),
          ),
        ),
      );
    }

    testWidgets('should render search input field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search in chat...'), findsOneWidget);
    });

    testWidgets('should render search button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should render back button', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('should show clear button when text is entered', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially no clear button
      expect(find.byIcon(Icons.clear), findsNothing);

      // Enter text
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      // Clear button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('should clear text when clear button is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter text
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.pump();

      // Verify text is entered
      expect(find.text('test query'), findsOneWidget);

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Text should be cleared
      expect(find.text('test query'), findsNothing);
    });

    testWidgets('should show navigation buttons when searching', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Initially no navigation buttons
      expect(find.byIcon(Icons.keyboard_arrow_up), findsNothing);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsNothing);

      // Enter text and search
      await tester.enterText(find.byType(TextField), 'test query');
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // Navigation buttons should appear
      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('should call onClose when back button is tapped', (WidgetTester tester) async {
      bool onCloseCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<MessageBloc>.value(
            value: messageBloc,
            child: Scaffold(
              body: ChatSearchBar(
                chatId: 'test_chat_id',
                onClose: () => onCloseCalled = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pump();

      expect(onCloseCalled, isTrue);
    });

    testWidgets('should submit search when enter is pressed', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Enter text
      await tester.enterText(find.byType(TextField), 'test query');
      
      // Submit by pressing enter
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Should trigger search (navigation buttons appear)
      expect(find.byIcon(Icons.keyboard_arrow_up), findsOneWidget);
      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });
  });
}
