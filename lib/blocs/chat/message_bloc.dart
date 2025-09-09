import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/message.dart';
import '../../models/user.dart';
import '../../services/mock_data_service.dart';

// Events
abstract class MessageEvent extends Equatable {
  const MessageEvent();

  @override
  List<Object?> get props => [];
}

class MessagesFetched extends MessageEvent {
  final String chatId;
  final int? page;

  const MessagesFetched({
    required this.chatId,
    this.page,
  });

  @override
  List<Object?> get props => [chatId, page];
}

class MessageSearchStarted extends MessageEvent {
  final String chatId;
  final String query;

  const MessageSearchStarted({
    required this.chatId,
    required this.query,
  });

  @override
  List<Object?> get props => [chatId, query];
}

class MessageSearchCleared extends MessageEvent {
  const MessageSearchCleared();

  @override
  List<Object?> get props => [];
}

class MessageSearchNext extends MessageEvent {
  const MessageSearchNext();

  @override
  List<Object?> get props => [];
}

class MessageSearchPrevious extends MessageEvent {
  const MessageSearchPrevious();

  @override
  List<Object?> get props => [];
}

class MessageSent extends MessageEvent {
  final Message message;

  const MessageSent(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageReceived extends MessageEvent {
  final Message message;

  const MessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageRetried extends MessageEvent {
  final Message failedMessage;

  const MessageRetried(this.failedMessage);

  @override
  List<Object?> get props => [failedMessage];
}

class MessageEdited extends MessageEvent {
  final String messageId;
  final String newContent;

  const MessageEdited({
    required this.messageId,
    required this.newContent,
  });

  @override
  List<Object?> get props => [messageId, newContent];
}

class MessageDeleted extends MessageEvent {
  final String messageId;

  const MessageDeleted(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class MessageReactionAdded extends MessageEvent {
  final String messageId;
  final String emoji;
  final String userId;

  const MessageReactionAdded({
    required this.messageId,
    required this.emoji,
    required this.userId,
  });

  @override
  List<Object?> get props => [messageId, emoji, userId];
}

class MessageReactionRemoved extends MessageEvent {
  final String messageId;
  final String emoji;
  final String userId;

  const MessageReactionRemoved({
    required this.messageId,
    required this.emoji,
    required this.userId,
  });

  @override
  List<Object?> get props => [messageId, emoji, userId];
}

class MessageForwarded extends MessageEvent {
  final Message originalMessage;
  final String targetChatId;
  final String? additionalText;

  const MessageForwarded({
    required this.originalMessage,
    required this.targetChatId,
    this.additionalText,
  });

  @override
  List<Object?> get props => [originalMessage, targetChatId, additionalText];
}

// States
abstract class MessageState extends Equatable {
  const MessageState();

  @override
  List<Object?> get props => [];
}

class MessageInitial extends MessageState {}

class MessagesLoadInProgress extends MessageState {}

class MessagesLoadSuccess extends MessageState {
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

class MessageSendInProgress extends MessageState {
  final Message message;
  final List<Message> currentMessages;

  const MessageSendInProgress({
    required this.message,
    required this.currentMessages,
  });

  @override
  List<Object?> get props => [message, currentMessages];
}

class MessageSendSuccess extends MessageState {
  final Message message;
  final List<Message> updatedMessages;

  const MessageSendSuccess({
    required this.message,
    required this.updatedMessages,
  });

  @override
  List<Object?> get props => [message, updatedMessages];
}

class MessageSendFailure extends MessageState {
  final Message message;
  final String error;
  final List<Message> currentMessages;

  const MessageSendFailure({
    required this.message,
    required this.error,
    required this.currentMessages,
  });

  @override
  List<Object?> get props => [message, error, currentMessages];
}

class MessageError extends MessageState {
  final String error;

  const MessageError(this.error);

  @override
  List<Object?> get props => [error];
}

class MessageSearchInProgress extends MessageState {
  final String query;
  final List<Message> currentMessages;

  const MessageSearchInProgress({
    required this.query,
    required this.currentMessages,
  });

  @override
  List<Object?> get props => [query, currentMessages];
}

class MessageSearchSuccess extends MessageState {
  final String query;
  final List<Message> searchResults;
  final int currentResultIndex;
  final List<Message> currentMessages;

  const MessageSearchSuccess({
    required this.query,
    required this.searchResults,
    required this.currentResultIndex,
    required this.currentMessages,
  });

  @override
  List<Object?> get props => [query, searchResults, currentResultIndex, currentMessages];
}

class MessageSearchNoResults extends MessageState {
  final String query;
  final List<Message> currentMessages;

  const MessageSearchNoResults({
    required this.query,
    required this.currentMessages,
  });

  @override
  List<Object?> get props => [query, currentMessages];
}

// Bloc
class MessageBloc extends Bloc<MessageEvent, MessageState> {
  MessageBloc() : super(MessageInitial()) {
    on<MessagesFetched>(_onMessagesFetched);
    on<MessageSent>(_onMessageSent);
    on<MessageReceived>(_onMessageReceived);
    on<MessageRetried>(_onMessageRetried);
    on<MessageEdited>(_onMessageEdited);
    on<MessageDeleted>(_onMessageDeleted);
    on<MessageSearchStarted>(_onMessageSearchStarted);
    on<MessageSearchCleared>(_onMessageSearchCleared);
    on<MessageSearchNext>(_onMessageSearchNext);
    on<MessageSearchPrevious>(_onMessageSearchPrevious);
    on<MessageReactionAdded>(_onMessageReactionAdded);
    on<MessageReactionRemoved>(_onMessageReactionRemoved);
    on<MessageForwarded>(_onMessageForwarded);
  }

  Future<void> _onMessagesFetched(
    MessagesFetched event,
    Emitter<MessageState> emit,
  ) async {
    emit(MessagesLoadInProgress());
    
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
      emit(MessageError(e.toString()));
    }
  }

  Future<void> _onMessageSent(
    MessageSent event,
    Emitter<MessageState> emit,
  ) async {
    if (state is MessagesLoadSuccess) {
      final currentState = state as MessagesLoadSuccess;
      final updatedMessages = [event.message, ...currentState.messages];
      
      // Show optimistic UI
      emit(MessageSendInProgress(
        message: event.message,
        currentMessages: updatedMessages,
      ));
      
      // Simulate API delay
      await Future.delayed(const Duration(milliseconds: 500));
      
      try {
        // Add message to mock data
        MockDataService.addMessage(event.message.chatId, event.message);
        
        // Update message status to sent
        final sentMessage = event.message.copyWith(status: MessageStatus.sent);
        final finalMessages = [sentMessage, ...currentState.messages];
        
        emit(MessageSendSuccess(
          message: sentMessage,
          updatedMessages: finalMessages,
        ));
      } catch (e) {
        emit(MessageSendFailure(
          message: event.message,
          error: e.toString(),
          currentMessages: currentState.messages,
        ));
      }
    }
  }

  void _onMessageReceived(
    MessageReceived event,
    Emitter<MessageState> emit,
  ) {
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

  Future<void> _onMessageRetried(
    MessageRetried event,
    Emitter<MessageState> emit,
  ) async {
    // Retry sending the failed message
    add(MessageSent(event.failedMessage));
  }

  Future<void> _onMessageEdited(
    MessageEdited event,
    Emitter<MessageState> emit,
  ) async {
    if (state is MessagesLoadSuccess) {
      final currentState = state as MessagesLoadSuccess;
      final updatedMessages = currentState.messages.map((message) {
        if (message.id == event.messageId) {
          return message.copyWith(
            content: event.newContent,
            editedAt: DateTime.now(),
          );
        }
        return message;
      }).toList();

      emit(MessagesLoadSuccess(
        chatId: currentState.chatId,
        messages: updatedMessages,
        hasMore: currentState.hasMore,
      ));
    }
  }

  Future<void> _onMessageDeleted(
    MessageDeleted event,
    Emitter<MessageState> emit,
  ) async {
    if (state is MessagesLoadSuccess) {
      final currentState = state as MessagesLoadSuccess;
      final updatedMessages = currentState.messages
          .where((message) => message.id != event.messageId)
          .toList();

      emit(MessagesLoadSuccess(
        chatId: currentState.chatId,
        messages: updatedMessages,
        hasMore: currentState.hasMore,
      ));
    }
  }

  // Search methods
  Future<void> _onMessageSearchStarted(
    MessageSearchStarted event,
    Emitter<MessageState> emit,
  ) async {
    if (state is MessagesLoadSuccess) {
      final currentState = state as MessagesLoadSuccess;
      
      emit(MessageSearchInProgress(
        query: event.query,
        currentMessages: currentState.messages,
      ));
      
      // Simulate search delay
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Perform search in messages
      final searchResults = currentState.messages.where((message) {
        final query = event.query.toLowerCase();
        return message.content.toLowerCase().contains(query) ||
               (message.fileName?.toLowerCase().contains(query) ?? false) ||
               (message.locationName?.toLowerCase().contains(query) ?? false);
      }).toList();
      
      if (searchResults.isNotEmpty) {
        emit(MessageSearchSuccess(
          query: event.query,
          searchResults: searchResults,
          currentResultIndex: 0,
          currentMessages: currentState.messages,
        ));
      } else {
        emit(MessageSearchNoResults(
          query: event.query,
          currentMessages: currentState.messages,
        ));
      }
    }
  }

  void _onMessageSearchCleared(
    MessageSearchCleared event,
    Emitter<MessageState> emit,
  ) {
    // Return to the last successful messages state
    if (state is MessageSearchSuccess) {
      final searchState = state as MessageSearchSuccess;
      emit(MessagesLoadSuccess(
        chatId: searchState.currentMessages.first.chatId,
        messages: searchState.currentMessages,
        hasMore: true,
      ));
    } else if (state is MessageSearchNoResults) {
      final noResultsState = state as MessageSearchNoResults;
      emit(MessagesLoadSuccess(
        chatId: noResultsState.currentMessages.first.chatId,
        messages: noResultsState.currentMessages,
        hasMore: true,
      ));
    }
  }

  void _onMessageSearchNext(
    MessageSearchNext event,
    Emitter<MessageState> emit,
  ) {
    if (state is MessageSearchSuccess) {
      final searchState = state as MessageSearchSuccess;
      final nextIndex = (searchState.currentResultIndex + 1) % searchState.searchResults.length;
      
      emit(MessageSearchSuccess(
        query: searchState.query,
        searchResults: searchState.searchResults,
        currentResultIndex: nextIndex,
        currentMessages: searchState.currentMessages,
      ));
    }
  }

  void _onMessageSearchPrevious(
    MessageSearchPrevious event,
    Emitter<MessageState> emit,
  ) {
    if (state is MessageSearchSuccess) {
      final searchState = state as MessageSearchSuccess;
      final prevIndex = searchState.currentResultIndex > 0 
          ? searchState.currentResultIndex - 1 
          : searchState.searchResults.length - 1;
      
      emit(MessageSearchSuccess(
        query: searchState.query,
        searchResults: searchState.searchResults,
        currentResultIndex: prevIndex,
        currentMessages: searchState.currentMessages,
      ));
    }
  }

  // Reaction methods
  void _onMessageReactionAdded(
    MessageReactionAdded event,
    Emitter<MessageState> emit,
  ) {
    if (state is MessagesLoadSuccess) {
      final currentState = state as MessagesLoadSuccess;
      final updatedMessages = currentState.messages.map((message) {
        if (message.id == event.messageId) {
          final currentReactions = Map<String, List<String>>.from(message.reactions ?? {});
          final emojiReactions = List<String>.from(currentReactions[event.emoji] ?? []);
          
          if (!emojiReactions.contains(event.userId)) {
            emojiReactions.add(event.userId);
            currentReactions[event.emoji] = emojiReactions;
          }
          
          return message.copyWith(reactions: currentReactions);
        }
        return message;
      }).toList();

      emit(MessagesLoadSuccess(
        chatId: currentState.chatId,
        messages: updatedMessages,
        hasMore: currentState.hasMore,
      ));
    }
  }

  void _onMessageReactionRemoved(
    MessageReactionRemoved event,
    Emitter<MessageState> emit,
  ) {
    if (state is MessagesLoadSuccess) {
      final currentState = state as MessagesLoadSuccess;
      final updatedMessages = currentState.messages.map((message) {
        if (message.id == event.messageId) {
          final currentReactions = Map<String, List<String>>.from(message.reactions ?? {});
          final emojiReactions = List<String>.from(currentReactions[event.emoji] ?? []);
          
          emojiReactions.remove(event.userId);
          if (emojiReactions.isEmpty) {
            currentReactions.remove(event.emoji);
          } else {
            currentReactions[event.emoji] = emojiReactions;
          }
          
          return message.copyWith(reactions: currentReactions);
        }
        return message;
      }).toList();

      emit(MessagesLoadSuccess(
        chatId: currentState.chatId,
        messages: updatedMessages,
        hasMore: currentState.hasMore,
      ));
    }
  }

  // Forwarding method
  Future<void> _onMessageForwarded(
    MessageForwarded event,
    Emitter<MessageState> emit,
  ) async {
    if (state is MessagesLoadSuccess) {
      final currentState = state as MessagesLoadSuccess;
      
      // Create a new forwarded message
      final forwardedMessage = Message(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: event.targetChatId,
        sender: MockDataService.currentUser,
        type: event.originalMessage.type,
        content: event.additionalText ?? event.originalMessage.content,
        mediaUrl: event.originalMessage.mediaUrl,
        fileName: event.originalMessage.fileName,
        fileSize: event.originalMessage.fileSize,
        voiceDuration: event.originalMessage.voiceDuration,
        latitude: event.originalMessage.latitude,
        longitude: event.originalMessage.longitude,
        locationName: event.originalMessage.locationName,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
        reactions: null,
      );

      // Add the forwarded message to the current chat
      final updatedMessages = [forwardedMessage, ...currentState.messages];
      
      emit(MessagesLoadSuccess(
        chatId: currentState.chatId,
        messages: updatedMessages,
        hasMore: currentState.hasMore,
      ));

      // TODO: Send the forwarded message to the target chat via repository
      // This would typically involve calling a repository method to send the message
      // to the target chat and updating the ChatBloc if needed
    }
  }
}
