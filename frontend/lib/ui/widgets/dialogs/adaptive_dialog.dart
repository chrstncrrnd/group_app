import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<void> showAdaptiveDialog(context,
    {required Widget title,
    Widget? content,
    required List<Widget> actions,
    MainAxisAlignment? actionsAlignment}) async {
  Platform.isIOS
      ? await showCupertinoDialog<String>(
          context: context,
          builder: (BuildContext context) => CupertinoAlertDialog(
            title: title,
            content: content,
            actions: actions,
          ),
        )
      : await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: title,
            content: content,
            actions: actions,
            actionsAlignment: actionsAlignment,
          ),
        );
}
