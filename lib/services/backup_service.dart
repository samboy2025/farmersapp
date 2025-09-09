import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/user.dart';
import 'mock_data_service.dart';

class BackupService {
  static const String _backupFileName = 'chatwave_backup.json';
  
  /// Export all chat data to a JSON file
  static Future<String> exportChatData() async {
    try {
      // Get all chats and messages
      final chats = MockDataService.chats;
      final allMessages = <String, List<Message>>{};
      
      // Collect messages for each chat
      for (final chat in chats) {
        allMessages[chat.id] = MockDataService.getMessages(chat.id);
      }
      
      // Create backup data structure
      final backupData = {
        'exportDate': DateTime.now().toIso8601String(),
        'version': '1.0.0',
        'chats': chats.map((chat) => chat.toJson()).toList(),
        'messages': allMessages.map((chatId, messages) => 
          MapEntry(chatId, messages.map((msg) => msg.toJson()).toList())
        ),
        'users': MockDataService.users.map((user) => user.toJson()).toList(),
      };
      
      // Convert to JSON
      final jsonData = jsonEncode(backupData);
      
      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final backupFile = File('${directory.path}/$_backupFileName');
      
      // Write backup file
      await backupFile.writeAsString(jsonData);
      
      return backupFile.path;
    } catch (e) {
      throw Exception('Failed to export chat data: $e');
    }
  }
  
  /// Share the backup file
  static Future<void> shareBackup() async {
    try {
      final backupPath = await exportChatData();
      await Share.shareXFiles([XFile(backupPath)], text: 'ChatWave Chat Backup');
    } catch (e) {
      throw Exception('Failed to share backup: $e');
    }
  }
  
  /// Import chat data from a JSON file
  static Future<void> importChatData(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Backup file not found');
      }
      
      final jsonData = await file.readAsString();
      final backupData = jsonDecode(jsonData) as Map<String, dynamic>;
      
      // Validate backup data
      if (!backupData.containsKey('version') || 
          !backupData.containsKey('chats') || 
          !backupData.containsKey('messages')) {
        throw Exception('Invalid backup file format');
      }
      
      // TODO: Implement actual import logic
      // This would typically involve:
      // 1. Validating the data
      // 2. Clearing existing data
      // 3. Importing new data
      // 4. Updating the database/repository
      
      // For now, we'll just validate the structure
      final chats = (backupData['chats'] as List).map((chatJson) => 
        Chat.fromJson(chatJson as Map<String, dynamic>)
      ).toList();
      
      final messages = (backupData['messages'] as Map<String, dynamic>).map(
        (chatId, messagesJson) => MapEntry(
          chatId, 
          (messagesJson as List).map((msgJson) => 
            Message.fromJson(msgJson as Map<String, dynamic>)
          ).toList()
        )
      );
      
      final users = (backupData['users'] as List).map((userJson) => 
        User.fromJson(userJson as Map<String, dynamic>)
      ).toList();
      
      // Log import summary
      print('Backup import summary:');
      print('- Chats: ${chats.length}');
      print('- Total messages: ${messages.values.fold(0, (sum, msgs) => sum + msgs.length)}');
      print('- Users: ${users.length}');
      
    } catch (e) {
      throw Exception('Failed to import chat data: $e');
    }
  }
  
  /// Get backup file info
  static Future<Map<String, dynamic>?> getBackupInfo(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        return null;
      }
      
      final jsonData = await file.readAsString();
      final backupData = jsonDecode(jsonData) as Map<String, dynamic>;
      
      return {
        'exportDate': backupData['exportDate'],
        'version': backupData['version'],
        'chatCount': (backupData['chats'] as List).length,
        'messageCount': (backupData['messages'] as Map<String, dynamic>)
            .values.fold(0, (sum, msgs) => sum + (msgs as List).length),
        'userCount': (backupData['users'] as List).length,
        'fileSize': await file.length(),
      };
    } catch (e) {
      return null;
    }
  }
  
  /// Check if a file is a valid backup file
  static Future<bool> isValidBackupFile(String filePath) async {
    try {
      final info = await getBackupInfo(filePath);
      return info != null;
    } catch (e) {
      return false;
    }
  }
}
