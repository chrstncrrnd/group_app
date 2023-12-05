import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_app/models/current_user.dart';

class CurrentUserProvider extends ChangeNotifier {
  CurrentUser? currentUser;

  void handleError(err) async {
    log("Error with current_user_provider: $err");
    // determine if the user has been deleted:
    FirebaseAuth.instance.currentUser?.reload();
  }

  CurrentUserProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        CurrentUser.asStream(id: user.uid).listen((event) {
          currentUser = event;
          notifyListeners();
        }).onError(handleError);
      } else {
        log("User signed out");
        currentUser = null;
      }
    }, onError: (err) async {
      log("Error with firebase auth", error: err);
      await FirebaseAuth.instance.signOut();
    });
  }
}
