import 'package:flutter/material.dart';
import '../../config/app_config.dart';

class AuthDropdown extends StatefulWidget {
  final String label;
  final String? hint;
  final List<String> items;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final bool isTablet;

  const AuthDropdown({
    super.key,
    required this.label,
    this.hint,
    required this.items,
    this.value,
    required this.onChanged,
    this.validator,
    this.prefixIcon,
    this.isTablet = false,
  });

  @override
  State<AuthDropdown> createState() => _AuthDropdownState();
}

class _AuthDropdownState extends State<AuthDropdown> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: widget.isTablet ? 16 : 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111B21),
          ),
        ),
        SizedBox(height: widget.isTablet ? 10 : 8),
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: DropdownButtonFormField<String>(
            value: widget.value,
            onChanged: widget.onChanged,
            validator: widget.validator,
            items: widget.items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: widget.isTablet ? 18 : 16,
                    color: const Color(0xFF111B21),
                  ),
                ),
              );
            }).toList(),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(
                color: const Color(0xFF667781),
                fontSize: widget.isTablet ? 18 : 16,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? AppConfig.primaryColor
                          : const Color(0xFF667781),
                      size: widget.isTablet ? 24 : 20,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppConfig.primaryColor,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppConfig.errorColor,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppConfig.errorColor,
                  width: 2,
                ),
              ),
              filled: true,
              fillColor: _isFocused
                  ? Colors.white
                  : const Color(0xFFF8F9FA),
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.isTablet ? 20 : 16,
                vertical: widget.isTablet ? 18 : 16,
              ),
            ),
            dropdownColor: Colors.white,
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            style: TextStyle(
              fontSize: widget.isTablet ? 18 : 16,
              color: const Color(0xFF111B21),
            ),
          ),
        ),
      ],
    );
  }
}
