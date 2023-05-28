import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/models/current_user_private_data.dart';

class CurrentUserProvider extends ChangeNotifier {
  CurrentUser? currentUser;
  CurrentUserPrivateData? privateData;

  CurrentUserProvider() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      log("auth state changed");
      if (user != null) {
        log("user was not null");
        CurrentUser.asStream(id: user.uid).listen((event) {
          currentUser = event;
          log("current user changed");
          notifyListeners();
        });
        CurrentUserPrivateData.asStream(userId: user.uid).listen((event) {
          privateData = event;
          log("current user private data changed");
          notifyListeners();
        });
      } else {
        log("user was null :(");
        currentUser = null;
        privateData = null;
      }
    });
  }
}
