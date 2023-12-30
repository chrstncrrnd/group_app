import 'package:flutter/material.dart' hide showAdaptiveDialog;
import 'package:go_router/go_router.dart';
import 'package:groopo/ui/widgets/dialogs/adaptive_dialog.dart';

Future<void> showAlert(BuildContext context,
    {required String title, String? content}) async {
  await showAdaptiveDialog(context,
      title: Text(title),
      content: content != null ? Text(content) : const SizedBox(),
      actions: [TextButton(onPressed: context.pop, child: const Text("Ok"))]);
}
