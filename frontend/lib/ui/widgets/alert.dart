import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/ui/widgets/adaptive_dialog.dart';

Future<void> showAlert(BuildContext context, {required String title}) async {
  await showAdaptiveDialog(context,
      title: Text(title),
      actions: [TextButton(onPressed: context.pop, child: const Text("Ok"))]);
}
