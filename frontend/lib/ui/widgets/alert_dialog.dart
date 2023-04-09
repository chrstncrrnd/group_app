import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void showAdaptiveDialog(
  context, {
  required Text title,
  required Text content,
  required List<Widget> actions,
}) {
  Platform.isIOS
      ? showCupertinoDialog<String>(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: title,
            content: content,
            actions: actions,
          ),
        )
      : showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: title,
            content: content,
            actions: actions,
          ),
        );
}
