// a convenient wrapper around future builder
import 'dart:async';

import 'package:flutter/material.dart';

class Suspense<T> extends StatelessWidget {
  const Suspense(
      {super.key,
      this.future,
      this.placeholder,
      required this.builder,
      this.error});

  final Future<T>? future;
  final Widget? placeholder;
  final Widget Function(BuildContext context, T? data) builder;
  final Widget? error;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ??
              const Center(child: CircularProgressIndicator.adaptive());
        } else if (snapshot.hasError) {
          return Center(child: error ?? const Text("Something went wrong..."));
        }
        return builder(context, snapshot.data);
      },
    );
  }
}
