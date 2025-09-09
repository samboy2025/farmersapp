import 'package:dio/dio.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/chat.dart';
import '../models/message.dart';


class ChatRepository {
  final Dio _dio;
  final String _baseUrl;
  WebSocketChannel? _webSocketChannel;

  ChatRepository({required Dio dio, required String baseUrl})
      : _dio = dio,
        _baseUrl = baseUrl;

  // REST API Methods
  Future<List<Chat>> getChats() async {
    try {
      final response = await _dio.get('$_baseUrl/chats');
      final chatsData = response.data['chats'] as List;
      return chatsData
          .map((chat) => Chat.fromJson(chat as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Message>> getMessages(String chatId, {int? page}) async {
    try {
      final response = await _dio.get(
        '$_baseUrl/chats/$chatId/messages',
        queryParameters: {'page': page},
      );
      final messagesData = response.data['messages'] as List;
      return messagesData
          .map((message) => Message.fromJson(message as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Message> sendMessage(Message message) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/chats/${message.chatId}/messages',
        data: message.toJson(),
      );
      return Message.fromJson(response.data['message'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> markAsRead(String chatId, String messageId) async {
    try {
      await _dio.put(
        '$_baseUrl/chats/$chatId/messages/$messageId/read',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Chat> createGroupChat({
    required String name,
    required List<String> participantIds,
    String? groupPicture,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/chats/group',
        data: {
          'name': name,
          'participant_ids': participantIds,
          'group_picture': groupPicture,
        },
      );
      return Chat.fromJson(response.data['chat'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> pinChat(String chatId, bool isPinned) async {
    try {
      await _dio.put(
        '$_baseUrl/chats/$chatId/pin',
        data: {'is_pinned': isPinned},
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // WebSocket Methods
  void connectWebSocket(String token) {
    final wsUrl = _baseUrl.replaceFirst('http', 'ws');
    _webSocketChannel = WebSocketChannel.connect(
      Uri.parse('$wsUrl/ws?token=$token'),
    );
  }

  void disconnectWebSocket() {
    _webSocketChannel?.sink.close();
    _webSocketChannel = null;
  }

  Stream<dynamic> get messageStream {
    if (_webSocketChannel == null) {
      throw Exception('WebSocket not connected');
    }
    return _webSocketChannel!.stream;
  }

  void sendWebSocketMessage(Map<String, dynamic> message) {
    if (_webSocketChannel == null) {
      throw Exception('WebSocket not connected');
    }
    _webSocketChannel!.sink.add(message);
  }

  // File Upload
  Future<String> uploadFile(String filePath, String fileName) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath, filename: fileName),
      });

      final response = await _dio.post(
        '$_baseUrl/upload',
        data: formData,
      );

      return response.data['file_url'] as String;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please try again.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message = e.response?.data['message'] ?? 'Operation failed';
        return Exception('$message (Status: $statusCode)');
      case DioExceptionType.cancel:
        return Exception('Request cancelled');
      default:
        return Exception('Network error. Please check your connection.');
    }
  }
}
