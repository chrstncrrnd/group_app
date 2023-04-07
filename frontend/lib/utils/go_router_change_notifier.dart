import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/routes.dart';

// A wrapper class around GoRouter to include firebase auth
// state changes and notifies listeners.
class GoRouterChangeNotifier extends ChangeNotifier {
  GoRouterChangeNotifier({this.signedIn = false, required this.routes}) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      signedIn = user != null;

      notifyListeners();
    });
  }

  bool signedIn;

  final Routes routes;
  GoRouter get router =>
      GoRouter(routes: routes.routes(signedIn), initialLocation: "/");
}
