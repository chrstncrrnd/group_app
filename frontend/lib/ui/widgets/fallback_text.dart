import 'package:flutter/material.dart';

class FbText extends Text {
  const FbText(this.text, {super.key, this.fallbackText = "An error occurred"})
      : super(text ?? fallbackText);

  final String? text;
  final String fallbackText;
}
