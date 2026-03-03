import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Minimal underline text field — matches mockup exactly.
/// Label sits above, thin bottom border only, no box.
class NezTextField extends StatefulWidget {
  const NezTextField({
    super.key,
    required this.hint,
    this.controller,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.onChanged,
    this.validator,
    this.autofillHints,
  });

  final String hint;
  final TextEditingController? controller;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final Iterable<String>? autofillHints;

  @override
  State<NezTextField> createState() => _NezTextFieldState();
}

class _NezTextFieldState extends State<NezTextField> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Text(
          widget.hint,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          onChanged: widget.onChanged,
          validator: widget.validator,
          autofillHints: widget.autofillHints,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: AppColors.textPrimary,
          ),
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: null,
            isDense: true,
            suffixIcon: widget.obscureText
                ? GestureDetector(
                    onTap: () => setState(() => _obscured = !_obscured),
                    child: Icon(
                      _obscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textHint,
                      size: 18,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
