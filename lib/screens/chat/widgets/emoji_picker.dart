import 'package:flutter/material.dart';
import '../../../config/app_config.dart';

class EmojiPicker extends StatelessWidget {
  final Function(String) onEmojiSelected;
  final VoidCallback onClose;

  const EmojiPicker({
    super.key,
    required this.onEmojiSelected,
    required this.onClose,
  });

  // Common emojis organized by category
  static const List<String> _recentEmojis = ['😊', '😂', '❤️', '👍', '😍', '🙌', '🔥', '💯'];
  static const List<String> _smileys = [
    '😀', '😃', '😄', '😁', '😆', '😅', '🤣', '😂', '🙂', '🙃', '😉', '😊', '😇',
    '🥰', '😍', '🤩', '😘', '😗', '☺️', '😚', '😙', '🥲', '😋', '😛', '😜', '🤪',
    '😝', '🤑', '🤗', '🤭', '🤫', '🤔', '🤐', '🤨', '😐', '😑', '😶', '😏', '😒',
    '🙄', '😬', '🤥', '😔', '😪', '🤤', '😴', '😷', '🤒', '🤕', '🤢', '🤮', '🤧',
    '🥵', '🥶', '🥴', '😵', '🤯', '🤠', '🥳', '🥸', '😎', '🤓', '🧐', '😕', '😟',
    '🙁', '☹️', '😮', '😯', '😲', '😳', '🥺', '😦', '😧', '😨', '😰', '😥', '😢',
    '😭', '😱', '😖', '😣', '😞', '😓', '😩', '😫', '🥱', '😤', '😡', '😠', '🤬',
    '😈', '👿', '💀', '☠️', '💩', '🤡', '👹', '👺', '👻', '👽', '👾', '🤖', '😺',
    '😸', '😹', '😻', '😼', '😽', '🙀', '😿', '😾'
  ];

  static const List<String> _gestures = [
    '👋', '🤚', '🖐️', '✋', '🖖', '👌', '🤌', '🤏', '✌️', '🤞', '🤟', '🤘', '🤙',
    '👈', '👉', '👆', '🖕', '👇', '☝️', '👍', '👎', '👊', '✊', '🤛', '🤜', '👏',
    '🙌', '👐', '🤲', '🤝', '🙏', '✍️', '💅', '🤳', '💪', '🦾', '🦿', '🦵', '🦶',
    '👂', '🦻', '👃', '🧠', '🫀', '🫁', '🦷', '🦴', '👀', '👁️', '👅', '👄', '💋',
    '🩸'
  ];


  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.35,
      color: Colors.white,
      child: Column(
        children: [
          // Header with close button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Emojis',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppConfig.primaryColor,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                  iconSize: 20,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),

          // Emoji categories
          Expanded(
            child: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  TabBar(
                    tabs: const [
                      Tab(text: 'Recent'),
                      Tab(text: 'Smileys'),
                      Tab(text: 'Gestures'),
                    ],
                    labelColor: AppConfig.primaryColor,
                    unselectedLabelColor: Colors.grey.shade600,
                    indicatorColor: AppConfig.primaryColor,
                    labelStyle: const TextStyle(fontSize: 12),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildEmojiGrid(_recentEmojis),
                        _buildEmojiGrid(_smileys),
                        _buildEmojiGrid(_gestures),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiGrid(List<String> emojis) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: emojis.length,
      itemBuilder: (context, index) {
        final emoji = emojis[index];
        return GestureDetector(
          onTap: () {
            onEmojiSelected(emoji);
            onClose();
          },
          child: Container(
            alignment: Alignment.center,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 24),
            ),
          ),
        );
      },
    );
  }
}
