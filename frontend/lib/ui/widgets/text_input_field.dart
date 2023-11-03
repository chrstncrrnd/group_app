import 'dart:async';

import 'package:flutter/material.dart';

class TextInputField extends StatelessWidget {
  const TextInputField(
      {super.key,
      required this.label,
      this.onChanged,
      this.validator,
      this.maxLines,
      this.minLines,
      this.initialValue,
      this.obscureText = false,
      this.textCapitalization = TextCapitalization.none});

  final String label;
  final FutureOr<void> Function(String)? onChanged;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? minLines;
  final String? initialValue;
  final bool obscureText;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          label: Text(label),
        ),
      obscureText: obscureText,
        maxLines: maxLines,
        minLines: minLines,
        onChanged: onChanged,
      validator: validator,
      textCapitalization: textCapitalization,
    );
  }
}
