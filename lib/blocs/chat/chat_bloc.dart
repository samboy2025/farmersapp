import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/chat.dart';
import '../../models/message.dart';
import '../../services/mock_data_service.dart';

// Events
abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ChatsFetched extends ChatEvent {}

class MessagesFetched extends ChatEvent {
  final String chatId;
  final int? page;

  const MessagesFetched({
    required this.chatId,
    this.page,
  });

  @override
  List<Object?> get props => [chatId, page];
}

class MessageSent extends ChatEvent {
  final Message message;

  const MessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageReceived extends ChatEvent {
  final Message message;

  const MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class AttachmentSelected extends ChatEvent {
  final String chatId;
  final String filePath;
  final String fileName;
  final MessageType type;

  const AttachmentSelected({
    required this.chatId,
    required this.filePath,
    required this.fileName,
    required this.type,
  });

  @override
  List<Object?> get props => [chatId, filePath, fileName, type];
}

class ChatPinned extends ChatEvent {
  final String chatId;
  final bool isPinned;

  const ChatPinned({
    required this.chatId,
    required this.isPinned,
  });

  @override
  List<Object?> get props => [chatId, isPinned];
}

class GroupChatCreated extends ChatEvent {
  final String name;
  final List<String> participantIds;
  final String? groupPicture;

  const GroupChatCreated({
    required this.name,
    required this.participantIds,
    this.groupPicture,
  });

  @override
  List<Object?> get props => [name, participantIds, groupPicture];
}

// States
abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatsLoadSuccess extends ChatState {
  final List<Chat> chats;

  const ChatsLoadSuccess(this.chats);

  @override
  List<Object?> get props => [chats];
}

class MessagesLoadSuccess extends ChatState {
  final String chatId;
  final List<Message> messages;
  final bool hasMore;

  const MessagesLoadSuccess({
    required this.chatId,
    required this.messages,
    this.hasMore = true,
  });

  @override
  List<Object?> get props => [chatId, messages, hasMore];
}

class MessageSending extends ChatState {
  final Message message;

  const MessageSending(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageSentSuccess extends ChatState {
  final Message message;

  const MessageSentSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageError extends ChatState {
  final String message;

  const MessageError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<ChatsFetched>(_onChatsFetched);
    on<MessagesFetched>(_onMessagesFetched);
    on<MessageSent>(_onMessageSent);
    on<MessageReceived>(_onMessageReceived);
    on<AttachmentSelected>(_onAttachmentSelected);
    on<ChatPinned>(_onChatPinned);
    on<GroupChatCreated>(_onGroupChatCreated);
  }

  Future<void> _onChatsFetched(
    ChatsFetched event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      final chats = MockDataService.chats;
      emit(ChatsLoadSuccess(chats));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onMessagesFetched(
    MessagesFetched event,
    Emitter<ChatState> emit,
  ) async {
    emit(ChatLoading());
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    try {
      final messages = MockDataService.getMessages(event.chatId);
      emit(MessagesLoadSuccess(
        chatId: event.chatId,
        messages: messages,
        hasMore: messages.length >= 20, // Assuming 20 messages per page
      ));
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onMessageSent(
    MessageSent event,
    Emitter<ChatState> emit,
  ) async {
    emit(MessageSending(event.message));
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      // Add message to mock data
      MockDataService.addMessage(event.message.chatId, event.message);
      emit(MessageSentSuccess(event.message));
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  void _onMessageReceived(
    MessageReceived event,
    Emitter<ChatState> emit,
  ) {
    // Handle real-time message reception
    // This would typically update the current state
    if (state is MessagesLoadSuccess) {
      final currentState = state as MessagesLoadSuccess;
      if (currentState.chatId == event.message.chatId) {
        final updatedMessages = [event.message, ...currentState.messages];
        emit(MessagesLoadSuccess(
          chatId: currentState.chatId,
          messages: updatedMessages,
          hasMore: currentState.hasMore,
        ));
      }
    }
  }

  Future<void> _onAttachmentSelected(
    AttachmentSelected event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Simulate file upload
      await Future.delayed(const Duration(seconds: 1));
      
      final message = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: event.chatId,
        sender: MockDataService.currentUser,
        type: event.type,
        content: event.fileName,
        mediaUrl: 'https://picsum.photos/200/300', // Mock media URL
        fileName: event.fileName,
        timestamp: DateTime.now(),
        status: MessageStatus.sending,
      );

      add(MessageSent(message));
    } catch (e) {
      emit(MessageError(e.toString()));
    }
  }

  Future<void> _onChatPinned(
    ChatPinned event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Refresh chats to show updated pin status
      add(ChatsFetched());
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }

  Future<void> _onGroupChatCreated(
    GroupChatCreated event,
    Emitter<ChatState> emit,
  ) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Refresh chats to show new group
      add(ChatsFetched());
    } catch (e) {
      emit(ChatError(e.toString()));
    }
  }
}
