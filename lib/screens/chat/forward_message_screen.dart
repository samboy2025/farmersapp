import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/chat/chat_bloc.dart' as chat_bloc;
import '../../config/app_config.dart';
import '../../models/message.dart';

class ForwardMessageScreen extends StatefulWidget {
  final Message messageToForward;

  const ForwardMessageScreen({
    super.key,
    required this.messageToForward,
  });

  @override
  State<ForwardMessageScreen> createState() => _ForwardMessageScreenState();
}

class _ForwardMessageScreenState extends State<ForwardMessageScreen> {
  final TextEditingController _additionalTextController = TextEditingController();
  String? _selectedChatId;

  @override
  void dispose() {
    _additionalTextController.dispose();
    super.dispose();
  }

  void _forwardMessage() {
    if (_selectedChatId != null) {
      // TODO: Implement forwarding via MessageBloc
      // This would involve navigating back and triggering the forward event
      Navigator.pop(context, {
        'targetChatId': _selectedChatId,
        'additionalText': _additionalTextController.text.trim(),
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forward Message'),
        backgroundColor: AppConfig.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedChatId != null)
            TextButton(
              onPressed: _forwardMessage,
              child: const Text(
                'Forward',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Message preview
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Forwarding:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                _buildMessagePreview(),
              ],
            ),
          ),
          
          // Additional text input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _additionalTextController,
              decoration: const InputDecoration(
                hintText: 'Add a message (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Chat selection
          Expanded(
            child: BlocBuilder<chat_bloc.ChatBloc, chat_bloc.ChatState>(
              builder: (context, state) {
                if (state is chat_bloc.ChatsLoadSuccess) {
                  return ListView.builder(
                    itemCount: state.chats.length,
                    itemBuilder: (context, index) {
                      final chat = state.chats[index];
                      final isSelected = chat.id == _selectedChatId;
                      
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: chat.groupPicture != null
                              ? NetworkImage(chat.groupPicture!)
                              : null,
                          backgroundColor: AppConfig.primaryColor,
                          child: chat.groupPicture == null
                              ? Text(
                                  chat.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        title: Text(chat.name),
                        subtitle: Text(
                          chat.isGroup ? 'Group • ${chat.participants.length} members' : 'Individual chat',
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: AppConfig.primaryColor,
                              )
                            : null,
                        onTap: () {
                          setState(() {
                            _selectedChatId = chat.id;
                          });
                        },
                      );
                    },
                  );
                } else if (state is chat_bloc.ChatLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return const Center(child: Text('No chats available'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagePreview() {
    switch (widget.messageToForward.type) {
      case MessageType.text:
        return Text(
          widget.messageToForward.content,
          style: const TextStyle(fontSize: 16),
        );
      case MessageType.image:
        return Row(
          children: [
            Icon(Icons.image, color: AppConfig.primaryColor),
            const SizedBox(width: 8),
            const Text('Image'),
            if (widget.messageToForward.content.isNotEmpty) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.messageToForward.content,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        );
      case MessageType.video:
        return Row(
          children: [
            Icon(Icons.video_file, color: AppConfig.primaryColor),
            const SizedBox(width: 8),
            const Text('Video'),
            if (widget.messageToForward.content.isNotEmpty) ...[
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.messageToForward.content,
                  style: const TextStyle(fontSize: 14),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        );
      case MessageType.file:
        return Row(
          children: [
            Icon(Icons.attach_file, color: AppConfig.primaryColor),
            const SizedBox(width: 8),
            Text(widget.messageToForward.fileName ?? 'File'),
          ],
        );
      case MessageType.voice:
        return Row(
          children: [
            Icon(Icons.mic, color: AppConfig.primaryColor),
            const SizedBox(width: 8),
            const Text('Voice message'),
            if (widget.messageToForward.voiceDuration != null) ...[
              const SizedBox(width: 8),
              Text('${widget.messageToForward.voiceDuration!.inSeconds}s'),
            ],
          ],
        );
      case MessageType.location:
        return Row(
          children: [
            Icon(Icons.location_on, color: AppConfig.primaryColor),
            const SizedBox(width: 8),
            Text(widget.messageToForward.locationName ?? 'Location'),
          ],
        );
      case MessageType.contact:
        return Row(
          children: [
            Icon(Icons.person, color: AppConfig.primaryColor),
            const SizedBox(width: 8),
            const Text('Contact'),
          ],
        );
    }
  }
}
