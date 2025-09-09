import 'package:flutter/material.dart';
import '../../../config/app_config.dart';

class ReactionPicker extends StatelessWidget {
  final Function(String emoji) onReactionSelected;
  final VoidCallback? onClose;

  const ReactionPicker({
    super.key,
    required this.onReactionSelected,
    this.onClose,
  });

  static const List<String> _reactions = [
    '👍', '❤️', '😊', '😂', '😮', '😢', '😡', '👏',
    '🙏', '🎉', '🔥', '💯', '✨', '🌟', '💪', '👀',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Add Reaction',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onClose != null)
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _reactions.length,
            itemBuilder: (context, index) {
              final emoji = _reactions[index];
              return GestureDetector(
                onTap: () {
                  onReactionSelected(emoji);
                  if (onClose != null) onClose!();
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class MessageReactions extends StatelessWidget {
  final Map<String, List<String>>? reactions;
  final String currentUserId;
  final Function(String emoji) onReactionTap;

  const MessageReactions({
    super.key,
    this.reactions,
    required this.currentUserId,
    required this.onReactionTap,
  });

  @override
  Widget build(BuildContext context) {
    if (reactions == null || reactions!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.65,
      ),
      child: Wrap(
        spacing: 4,
        runSpacing: 2,
        children: reactions!.entries.map((entry) {
          final emoji = entry.key;
          final userIds = entry.value;
          final hasReacted = userIds.contains(currentUserId);
          
          return GestureDetector(
            onTap: () => onReactionTap(emoji),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: hasReacted 
                    ? AppConfig.primaryColor.withOpacity(0.2)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hasReacted 
                      ? AppConfig.primaryColor
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (userIds.length > 1) ...[
                    const SizedBox(width: 4),
                    Text(
                      '${userIds.length}',
                      style: TextStyle(
                        fontSize: 10,
                        color: hasReacted 
                            ? AppConfig.primaryColor
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
