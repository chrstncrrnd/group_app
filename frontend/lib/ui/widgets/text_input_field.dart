import 'dart:async';

import 'package:flutter/material.dart';

class TextInputField extends StatelessWidget {
  const TextInputField(
      {super.key,
      required this.label,
      this.onChanged,
      this.validator,
      this.maxLines,
      this.minLines});

  final String label;
  final FutureOr<void> Function(String)? onChanged;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
        decoration: InputDecoration(
          label: Text(label),
        ),
        maxLines: maxLines,
        minLines: minLines,
        onChanged: onChanged,
        validator: validator);
  }
}
