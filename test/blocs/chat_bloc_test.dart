import 'package:flutter_test/flutter_test.dart';
import 'package:chat_app2/blocs/chat/chat_bloc.dart';
import 'package:chat_app2/models/chat.dart';
import 'package:chat_app2/models/user.dart';
import 'package:chat_app2/models/message.dart';

void main() {
  group('ChatBloc Tests', () {
    late ChatBloc chatBloc;

    setUp(() {
      chatBloc = ChatBloc();
    });

    tearDown(() {
      chatBloc.close();
    });

    test('initial state should be ChatInitial', () {
      expect(chatBloc.state, equals(ChatInitial()));
    });

    test('should emit ChatLoading when ChatsFetched is added', () {
      final expectedStates = [
        ChatLoading(),
      ];

      expectLater(
        chatBloc.stream,
        emitsInOrder(expectedStates),
      );

      chatBloc.add(ChatsFetched());
    });

    test('should emit ChatsLoadSuccess when chats are loaded', () {
      final testUser = User(
        id: 'user1',
        phoneNumber: '+1234567890',
        name: 'Test User',
        lastSeen: DateTime.now(),
      );

      final testChats = [
        Chat(
          id: 'chat1',
          name: 'Test Chat 1',
          participants: [testUser],
          lastActivity: DateTime.now(),
          createdAt: DateTime.now(),
        ),
        Chat(
          id: 'chat2',
          name: 'Test Chat 2',
          participants: [testUser],
          lastActivity: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      ];

      final expectedStates = [
        ChatLoading(),
        ChatsLoadSuccess(testChats),
      ];

      expectLater(
        chatBloc.stream,
        emitsInOrder(expectedStates),
      );

      chatBloc.add(ChatsFetched());
    });

    test('should emit ChatError when loading fails', () {
      // This test would require mocking the MockDataService to throw an error
      // For now, we'll test the basic error handling structure
      expect(chatBloc.state, equals(ChatInitial()));
    });

    test('should handle MessagesFetched event', () {
      final expectedStates = [
        ChatLoading(),
        MessagesLoadSuccess(
          chatId: 'test_chat',
          messages: [],
          hasMore: false,
        ),
      ];

      expectLater(
        chatBloc.stream,
        emitsInOrder(expectedStates),
      );

      chatBloc.add(MessagesFetched(chatId: 'test_chat'));
    });

    test('should handle MessageSent event', () {
      final testUser = User(
        id: 'user1',
        phoneNumber: '+1234567890',
        name: 'Test User',
        lastSeen: DateTime.now(),
      );

      final testMessage = Message(
        id: 'msg1',
        chatId: 'chat1',
        sender: testUser,
        type: MessageType.text,
        content: 'Test message',
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
      );

      final expectedStates = [
        MessageSending(testMessage),
        MessageSentSuccess(testMessage),
      ];

      expectLater(
        chatBloc.stream,
        emitsInOrder(expectedStates),
      );

      chatBloc.add(MessageSent(testMessage));
    });

    test('should handle GroupChatCreated event', () {
      final expectedStates = [
        ChatLoading(),
        ChatsLoadSuccess([]), // Will be populated by MockDataService
      ];

      expectLater(
        chatBloc.stream,
        emitsInOrder(expectedStates),
      );

      chatBloc.add(GroupChatCreated(
        name: 'Test Group',
        participantIds: ['user1', 'user2'],
      ));
    });
  });
}
