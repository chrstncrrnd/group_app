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
      if (user != null) {
        CurrentUser.asStream(id: user.uid).listen((event) {
          currentUser = event;
          notifyListeners();
        });
        CurrentUserPrivateData.asStream(userId: user.uid).listen((event) {
          privateData = event;
          notifyListeners();
        });
      } else {
        log("User signed out");
        currentUser = null;
        privateData = null;
      }
    });
  }
}
