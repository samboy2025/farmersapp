import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class StatusTextFormattingScreen extends StatefulWidget {
  final String initialText;
  final Function(String, Map<String, dynamic>) onFormattingComplete;

  const StatusTextFormattingScreen({
    super.key,
    required this.initialText,
    required this.onFormattingComplete,
  });

  @override
  State<StatusTextFormattingScreen> createState() => _StatusTextFormattingScreenState();
}

class _StatusTextFormattingScreenState extends State<StatusTextFormattingScreen> {
  final TextEditingController _textController = TextEditingController();
  Map<String, dynamic> _formatting = {
    'fontFamily': 'Default',
    'fontSize': 16.0,
    'fontWeight': FontWeight.normal,
    'fontStyle': FontStyle.normal,
    'color': Colors.black,
    'backgroundColor': Colors.transparent,
    'alignment': TextAlign.left,
    'textDecoration': TextDecoration.none,
  };

  final List<String> _fontFamilies = [
    'Default',
    'Roboto',
    'Arial',
    'Times New Roman',
    'Courier New',
    'Georgia',
    'Verdana',
  ];

  final List<Color> _textColors = [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
  ];

  final List<Color> _backgroundColors = [
    Colors.transparent,
    Colors.black.withOpacity(0.5),
    Colors.white.withOpacity(0.5),
    Colors.red.withOpacity(0.5),
    Colors.blue.withOpacity(0.5),
    Colors.green.withOpacity(0.5),
    Colors.yellow.withOpacity(0.5),
    Colors.purple.withOpacity(0.5),
  ];

  @override
  void initState() {
    super.initState();
    _textController.text = widget.initialText;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConfig.darkBackground : AppConfig.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Text Formatting',
          style: TextStyle(
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onFormattingComplete(_textController.text, _formatting);
              Navigator.of(context).pop();
            },
            child: Text(
              'Apply',
              style: TextStyle(
                color: AppConfig.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text Preview
            _buildTextPreview(isDark),

            const SizedBox(height: 24),

            // Text Input
            _buildTextInput(isDark),

            const SizedBox(height: 24),

            // Formatting Options
            _buildFormattingOptions(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildTextPreview(bool isDark) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          color: _formatting['backgroundColor'],
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
        child: Center(
          child: Text(
            _textController.text.isEmpty ? 'Your text here...' : _textController.text,
            style: TextStyle(
              fontFamily: _formatting['fontFamily'] == 'Default' ? null : _formatting['fontFamily'],
              fontSize: _formatting['fontSize'],
              fontWeight: _formatting['fontWeight'],
              fontStyle: _formatting['fontStyle'],
              color: _formatting['color'],
              decoration: _formatting['textDecoration'],
            ),
            textAlign: _formatting['alignment'],
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: TextField(
        controller: _textController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Enter your status text...',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.all(16),
        ),
        style: TextStyle(
          color: isDark ? AppConfig.darkText : AppConfig.lightText,
        ),
        onChanged: (value) {
          setState(() {});
        },
      ),
    );
  }

  Widget _buildFormattingOptions(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Font Family
        _buildSection(
          title: 'Font',
          child: _buildFontSelector(isDark),
          isDark: isDark,
        ),

        const SizedBox(height: 16),

        // Font Size
        _buildSection(
          title: 'Size',
          child: _buildFontSizeSelector(isDark),
          isDark: isDark,
        ),

        const SizedBox(height: 16),

        // Text Style
        _buildSection(
          title: 'Style',
          child: _buildTextStyleSelector(isDark),
          isDark: isDark,
        ),

        const SizedBox(height: 16),

        // Colors
        _buildSection(
          title: 'Colors',
          child: _buildColorSelectors(isDark),
          isDark: isDark,
        ),

        const SizedBox(height: 16),

        // Alignment
        _buildSection(
          title: 'Alignment',
          child: _buildAlignmentSelector(isDark),
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildSection({required String title, required Widget child, required bool isDark}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppConfig.darkText : AppConfig.lightText,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildFontSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: DropdownButtonFormField<String>(
        value: _formatting['fontFamily'],
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        items: _fontFamilies.map((font) {
          return DropdownMenuItem(
            value: font,
            child: Text(
              font,
              style: TextStyle(
                fontFamily: font == 'Default' ? null : font,
                color: isDark ? AppConfig.darkText : AppConfig.lightText,
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _formatting['fontFamily'] = value;
            });
          }
        },
      ),
    );
  }

  Widget _buildFontSizeSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: Column(
        children: [
          Slider(
            value: _formatting['fontSize'],
            min: 12,
            max: 48,
            divisions: 9,
            label: '${_formatting['fontSize'].round()}',
            onChanged: (value) {
              setState(() {
                _formatting['fontSize'] = value;
              });
            },
            activeColor: AppConfig.primaryColor,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Small',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                ),
              ),
              Text(
                'Large',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppConfig.darkTextSecondary : AppConfig.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextStyleSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStyleButton(
            icon: Icons.format_bold,
            isSelected: _formatting['fontWeight'] == FontWeight.bold,
            onTap: () {
              setState(() {
                _formatting['fontWeight'] = _formatting['fontWeight'] == FontWeight.bold
                    ? FontWeight.normal
                    : FontWeight.bold;
              });
            },
          ),
          _buildStyleButton(
            icon: Icons.format_italic,
            isSelected: _formatting['fontStyle'] == FontStyle.italic,
            onTap: () {
              setState(() {
                _formatting['fontStyle'] = _formatting['fontStyle'] == FontStyle.italic
                    ? FontStyle.normal
                    : FontStyle.italic;
              });
            },
          ),
          _buildStyleButton(
            icon: Icons.format_underlined,
            isSelected: _formatting['textDecoration'] == TextDecoration.underline,
            onTap: () {
              setState(() {
                _formatting['textDecoration'] = _formatting['textDecoration'] == TextDecoration.underline
                    ? TextDecoration.none
                    : TextDecoration.underline;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStyleButton({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppConfig.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppConfig.primaryColor : AppConfig.darkTextSecondary,
        ),
      ),
    );
  }

  Widget _buildColorSelectors(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Text Color',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppConfig.darkText : AppConfig.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _textColors.map((color) {
              return _buildColorButton(
                color: color,
                isSelected: _formatting['color'] == color,
                onTap: () {
                  setState(() {
                    _formatting['color'] = color;
                  });
                },
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          Text(
            'Background Color',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppConfig.darkText : AppConfig.lightText,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _backgroundColors.map((color) {
              return _buildColorButton(
                color: color,
                isSelected: _formatting['backgroundColor'] == color,
                onTap: () {
                  setState(() {
                    _formatting['backgroundColor'] = color;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildColorButton({
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? AppConfig.primaryColor : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: isSelected
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              )
            : null,
      ),
    );
  }

  Widget _buildAlignmentSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppConfig.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildAlignmentButton(
            icon: Icons.format_align_left,
            alignment: TextAlign.left,
            isSelected: _formatting['alignment'] == TextAlign.left,
            onTap: () {
              setState(() {
                _formatting['alignment'] = TextAlign.left;
              });
            },
          ),
          _buildAlignmentButton(
            icon: Icons.format_align_center,
            alignment: TextAlign.center,
            isSelected: _formatting['alignment'] == TextAlign.center,
            onTap: () {
              setState(() {
                _formatting['alignment'] = TextAlign.center;
              });
            },
          ),
          _buildAlignmentButton(
            icon: Icons.format_align_right,
            alignment: TextAlign.right,
            isSelected: _formatting['alignment'] == TextAlign.right,
            onTap: () {
              setState(() {
                _formatting['alignment'] = TextAlign.right;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlignmentButton({
    required IconData icon,
    required TextAlign alignment,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppConfig.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppConfig.primaryColor : AppConfig.darkTextSecondary,
        ),
      ),
    );
  }
}
