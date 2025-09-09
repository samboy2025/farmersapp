import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app2/blocs/chat/message_bloc.dart';
import 'package:chat_app2/models/message.dart';
import 'package:chat_app2/models/user.dart';

void main() {
  group('MessageBloc', () {
    late MessageBloc messageBloc;

    setUp(() {
      messageBloc = MessageBloc();
    });

    tearDown(() {
      messageBloc.close();
    });

    test('initial state should be MessageInitial', () {
      expect(messageBloc.state, equals(MessageInitial()));
    });

    test('should emit MessagesLoadInProgress when MessagesFetched is added', () {
      final expectedStates = [
        isA<MessagesLoadInProgress>(),
      ];

      expectLater(
        messageBloc.stream,
        emitsInOrder(expectedStates),
      );

      messageBloc.add(const MessagesFetched(chatId: 'chat_123'));
    });

    test('should emit correct states when MessageSent is added', () {
      final testMessage = Message(
        id: 'msg_new',
        chatId: 'chat_123',
        sender: User(
          id: 'current_user',
          phoneNumber: '+1234567890',
          name: 'Current User',
          lastSeen: DateTime.now(),
        ),
        type: MessageType.text,
        content: 'New message',
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      // First set the bloc to a valid state
      messageBloc.emit(MessagesLoadSuccess(
        chatId: 'chat_123',
        messages: [
          Message(
            id: 'msg_1',
            chatId: 'chat_123',
            sender: User(
              id: 'user_1',
              phoneNumber: '+1234567891',
              name: 'John Doe',
              lastSeen: DateTime.now(),
            ),
            type: MessageType.text,
            content: 'Hello there!',
            timestamp: DateTime.now(),
          ),
        ],
      ));

      final expectedStates = [
        isA<MessageSendInProgress>(),
        isA<MessageSendSuccess>(),
      ];

      expectLater(
        messageBloc.stream,
        emitsInOrder(expectedStates),
      );

      messageBloc.add(MessageSent(testMessage));
    });

    test('should emit correct states when MessageSearchStarted is added', () {
      final testMessages = [
        Message(
          id: 'msg_1',
          chatId: 'chat_123',
          sender: User(
            id: 'user_1',
            phoneNumber: '+1234567890',
            name: 'John Doe',
            lastSeen: DateTime.now(),
          ),
          type: MessageType.text,
          content: 'Hello there!',
          timestamp: DateTime.now(),
        ),
        Message(
          id: 'msg_2',
          chatId: 'chat_123',
          sender: User(
            id: 'user_2',
            phoneNumber: '+1234567891',
            name: 'Jane Smith',
            lastSeen: DateTime.now(),
          ),
          type: MessageType.text,
          content: 'Hi John!',
          timestamp: DateTime.now(),
        ),
      ];

      // Set the bloc to a valid state
      messageBloc.emit(MessagesLoadSuccess(
        chatId: 'chat_123',
        messages: testMessages,
      ));

      final expectedStates = [
        isA<MessageSearchInProgress>(),
        isA<MessageSearchSuccess>(),
      ];

      expectLater(
        messageBloc.stream,
        emitsInOrder(expectedStates),
      );

      messageBloc.add(const MessageSearchStarted(chatId: 'chat_123', query: 'Hello'));
    });

    test('should emit correct states when MessageSearchCleared is added', () {
      // Set the bloc to a search state
      messageBloc.emit(MessageSearchSuccess(
        query: 'test',
        searchResults: [],
        currentResultIndex: 0,
        currentMessages: [
          Message(
            id: 'msg_1',
            chatId: 'chat_123',
            sender: User(
              id: 'user_1',
              phoneNumber: '+1234567890',
              name: 'John Doe',
              lastSeen: DateTime.now(),
            ),
            type: MessageType.text,
            content: 'Hello there!',
            timestamp: DateTime.now(),
          ),
        ],
      ));

      final expectedStates = [
        isA<MessagesLoadSuccess>(),
      ];

      expectLater(
        messageBloc.stream,
        emitsInOrder(expectedStates),
      );

      messageBloc.add(const MessageSearchCleared());
    });

    test('should emit correct states when MessageReactionAdded is added', () {
      final testMessage = Message(
        id: 'msg_1',
        chatId: 'chat_123',
        sender: User(
          id: 'user_1',
          phoneNumber: '+1234567890',
          name: 'John Doe',
          lastSeen: DateTime.now(),
        ),
        type: MessageType.text,
        content: 'Hello there!',
        timestamp: DateTime.now(),
      );

      // Set the bloc to a valid state
      messageBloc.emit(MessagesLoadSuccess(
        chatId: 'chat_123',
        messages: [testMessage],
      ));

      final expectedStates = [
        isA<MessagesLoadSuccess>(),
      ];

      expectLater(
        messageBloc.stream,
        emitsInOrder(expectedStates),
      );

      messageBloc.add(const MessageReactionAdded(
        messageId: 'msg_1',
        emoji: '👍',
        userId: 'current_user',
      ));
    });

    test('should emit correct states when MessageForwarded is added', () {
      final originalMessage = Message(
        id: 'msg_1',
        chatId: 'chat_123',
        sender: User(
          id: 'user_1',
          phoneNumber: '+1234567890',
          name: 'John Doe',
          lastSeen: DateTime.now(),
        ),
        type: MessageType.text,
        content: 'Hello there!',
        timestamp: DateTime.now(),
      );

      // Set the bloc to a valid state
      messageBloc.emit(MessagesLoadSuccess(
        chatId: 'chat_123',
        messages: [originalMessage],
      ));

      final expectedStates = [
        isA<MessagesLoadSuccess>(),
      ];

      expectLater(
        messageBloc.stream,
        emitsInOrder(expectedStates),
      );

      messageBloc.add(MessageForwarded(
        originalMessage: originalMessage,
        targetChatId: 'chat_456',
        additionalText: 'Forwarded message',
      ));
    });
  });
}
