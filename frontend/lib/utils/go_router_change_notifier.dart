import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// A wrapper class around GoRouter to include firebase auth
// state changes and notifies listeners.
class GoRouterChangeNotifier extends ChangeNotifier {
  GoRouterChangeNotifier({required this.router}) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      notifyListeners();
    });
  }
  final GoRouter router;
}
