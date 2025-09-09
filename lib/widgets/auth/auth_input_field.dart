import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/app_config.dart';

class AuthInputField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;
  final bool readOnly;
  final int? maxLines;
  final bool autofocus;
  final bool isTablet;

  const AuthInputField({
    super.key,
    required this.label,
    this.hint,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.prefixIcon,
    this.suffix,
    this.validator,
    this.inputFormatters,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.autofocus = false,
    this.isTablet = false,
  });

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  bool _isFocused = false;
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: widget.isTablet ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppConfig.darkText : const Color(0xFF111B21),
          ),
        ),
        SizedBox(height: widget.isTablet ? 10 : 8),
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: TextFormField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText && !_isPasswordVisible,
            validator: widget.validator,
            inputFormatters: widget.inputFormatters,
            onTap: widget.onTap,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            autofocus: widget.autofocus,
            style: TextStyle(
              fontSize: widget.isTablet ? 18 : 16,
              color: isDark ? AppConfig.darkText : const Color(0xFF111B21),
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
                fontSize: widget.isTablet ? 18 : 16,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? AppConfig.primaryColor
                          : (isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781)),
                      size: widget.isTablet ? 24 : 20,
                    )
                  : null,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: isDark ? AppConfig.darkTextSecondary : const Color(0xFF667781),
                        size: widget.isTablet ? 24 : 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    )
                  : widget.suffix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : const Color(0xFFE5E5E5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: isDark ? Colors.grey.shade700 : const Color(0xFFE5E5E5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppConfig.primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppConfig.errorColor,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: AppConfig.errorColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: _isFocused
                  ? (isDark ? AppConfig.darkSurface : Colors.white)
                  : (isDark ? AppConfig.darkCard : const Color(0xFFF8F9FA)),
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.isTablet ? 20 : 16,
                vertical: widget.isTablet ? 18 : 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
