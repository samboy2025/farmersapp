import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app2/blocs/chat/message_bloc.dart';
import 'package:chat_app2/models/message.dart';
import 'package:chat_app2/models/user.dart';

void main() {
  group('MessageBloc Tests', () {
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
        MessagesLoadInProgress(),
      ];

      expectLater(
        messageBloc.stream,
        emitsInOrder(expectedStates),
      );

      messageBloc.add(MessagesFetched(chatId: 'test_chat'));
    });

    test('should emit MessagesLoadSuccess when messages are loaded', () {
      final expectedStates = [
        MessagesLoadInProgress(),
        MessagesLoadSuccess(
          chatId: '999',
          messages: [], // MockDataService returns empty list for new chat IDs
          hasMore: false,
        ),
      ];

      expectLater(
        messageBloc.stream,
        emitsInOrder(expectedStates),
      );

      messageBloc.add(MessagesFetched(chatId: '999')); // Use a chat ID that doesn't exist
    });

    test('should emit MessageSendInProgress when MessageSent is added', () {
      final testUser = User(
        id: 'user1',
        phoneNumber: '+1234567890',
        name: 'Test User',
        lastSeen: DateTime.now(),
      );

      final testMessage = Message(
        id: 'msg1',
        chatId: '1',
        sender: testUser,
        type: MessageType.text,
        content: 'Test message',
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
        reactions: null,
      );

      // First set the bloc to a valid state
      messageBloc.emit(MessagesLoadSuccess(
        chatId: '1',
        messages: [],
        hasMore: false,
      ));

      final expectedStates = [
        MessageSendInProgress(
          message: testMessage,
          currentMessages: [testMessage],
        ),
      ];

      expectLater(
        messageBloc.stream,
        emitsInOrder(expectedStates),
      );

      messageBloc.add(MessageSent(testMessage));
    });

    test('should emit MessageSearchInProgress when search is started', () {
      // First set the bloc to a valid state
      messageBloc.emit(MessagesLoadSuccess(
        chatId: '1',
        messages: [],
        hasMore: false,
      ));

      final expectedStates = [
        MessageSearchInProgress(
          query: 'test',
          currentMessages: [],
        ),
      ];

      expectLater(
        messageBloc.stream,
        emitsInOrder(expectedStates),
      );

      messageBloc.add(MessageSearchStarted(
        chatId: '1',
        query: 'test',
      ));
    });

    test('should emit MessageSearchSuccess when search finds results', () {
      final testUser = User(
        id: 'user1',
        phoneNumber: '+1234567890',
        name: 'Test User',
        lastSeen: DateTime.now(),
      );

      final testMessages = [
        Message(
          id: 'msg1',
          chatId: '1',
          sender: testUser,
          type: MessageType.text,
          content: 'Test message with search term',
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
          reactions: null,
        ),
      ];

      // First set the bloc to a valid state with messages
      messageBloc.emit(MessagesLoadSuccess(
        chatId: '1',
        messages: testMessages,
        hasMore: false,
      ));

      final expectedStates = [
        MessageSearchInProgress(
          query: 'search term',
          currentMessages: testMessages,
        ),
        MessageSearchSuccess(
          query: 'search term',
          searchResults: testMessages,
          currentResultIndex: 0,
          currentMessages: testMessages,
        ),
      ];

      expectLater(
        messageBloc.stream,
        emitsInOrder(expectedStates),
      );

      messageBloc.add(MessageSearchStarted(
        chatId: '1',
        query: 'search term',
      ));
    });

    test('should emit MessageSearchNoResults when search finds nothing', () {
      const query = 'nonexistent term';

      // First set the bloc to a valid state
      messageBloc.emit(MessagesLoadSuccess(
        chatId: '1',
        messages: [],
        hasMore: false,
      ));

      final expectedStates = [
        MessageSearchInProgress(
          query: query,
          currentMessages: [],
        ),
        MessageSearchNoResults(
          query: query,
          currentMessages: [],
        ),
      ];

      expectLater(
        messageBloc.stream,
        emitsInOrder(expectedStates),
      );

      messageBloc.add(MessageSearchStarted(
        chatId: '1',
        query: query,
      ));
    });

    test('should handle message reactions', () {
      final testUser = User(
        id: 'user1',
        phoneNumber: '+1234567890',
        name: 'Test User',
        lastSeen: DateTime.now(),
      );

      final testMessage = Message(
        id: 'msg1',
        chatId: '1',
        sender: testUser,
        type: MessageType.text,
        content: 'Test message',
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
        reactions: null,
      );

      // First set the bloc to a valid state
      messageBloc.emit(MessagesLoadSuccess(
        chatId: '1',
        messages: [testMessage],
        hasMore: false,
      ));

      final expectedStates = [
        MessagesLoadSuccess(
          chatId: '1',
          messages: [testMessage.copyWith(
            reactions: {'👍': ['user1']},
          )],
          hasMore: false,
        ),
      ];

      expectLater(
        messageBloc.stream,
        emitsInOrder(expectedStates),
      );

      messageBloc.add(MessageReactionAdded(
        messageId: 'msg1',
        emoji: '👍',
        userId: 'user1',
      ));
    });

    test('should handle message forwarding', () {
      final testUser = User(
        id: 'user1',
        phoneNumber: '+1234567890',
        name: 'Test User',
        lastSeen: DateTime.now(),
      );

      final testMessage = Message(
        id: 'msg1',
        chatId: '1',
        sender: testUser,
        type: MessageType.text,
        content: 'Test message',
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
        reactions: null,
      );

      // First set the bloc to a valid state
      messageBloc.emit(MessagesLoadSuccess(
        chatId: '1',
        messages: [testMessage],
        hasMore: false,
      ));

      // The forwarded message will be added to the current chat
      // We can't predict the exact ID and timestamp, so we'll just verify the state change
      final expectedStates = [
        isA<MessagesLoadSuccess>(),
      ];

      expectLater(
        messageBloc.stream,
        emitsInOrder(expectedStates),
      );

      messageBloc.add(MessageForwarded(
        originalMessage: testMessage,
        targetChatId: '2',
        additionalText: 'Forwarded message',
      ));
    });

    test('should handle message retry', () {
      final testUser = User(
        id: 'user1',
        phoneNumber: '+1234567890',
        name: 'Test User',
        lastSeen: DateTime.now(),
      );

      final failedMessage = Message(
        id: 'msg1',
        chatId: '1',
        sender: testUser,
        type: MessageType.text,
        content: 'Failed message',
        timestamp: DateTime.now(),
        status: MessageStatus.failed,
        reactions: null,
      );

      // First set the bloc to a valid state
      messageBloc.emit(MessagesLoadSuccess(
        chatId: '1',
        messages: [failedMessage],
        hasMore: false,
      ));

      final expectedStates = [
        MessageSendInProgress(
          message: failedMessage,
          currentMessages: [failedMessage, failedMessage],
        ),
        MessageSendSuccess(
          message: failedMessage.copyWith(status: MessageStatus.sent),
          updatedMessages: [failedMessage.copyWith(status: MessageStatus.sent), failedMessage],
        ),
      ];

      expectLater(
        messageBloc.stream,
        emitsInOrder(expectedStates),
      );

      messageBloc.add(MessageRetried(failedMessage));
    });
  });
}
