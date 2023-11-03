// Services to use for auth such as logging the user in and out,
// creating a new account, dealing with profile and stuff like that

// Returns null if successful, otherwise string with what went wrong
import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:group_app/utils/validators.dart';

Future<String?> logUserIn(String email, String password) async {
  var emailValid = validateEmail(email);
  if (emailValid != null) {
    return emailValid;
  }

  var passwordValid = validatePassword(password);
  if (passwordValid != null) {
    return passwordValid;
  }

  try {
    await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
    return null;
  } on FirebaseAuthException catch (error) {
    log(error.toString());
    return error.message.toString();
  } catch (error) {
    log(error.toString());
    return "An error occurred";
  }
}

Future<String?> usernameAvailable(String username) async {
  try {
    var res = await FirebaseFunctions.instance
        .httpsCallable("usernameAvailable")
        .call({"username": username});
    if (!res.data) {
      return "Username taken";
    }
  } on FirebaseFunctionsException catch (e) {
    log(e.toString());
    return e.message;
  }
  return null;
}

Future<String?> createUser(
    String email, String password, String username, String? name) async {
  log("Username: $username, name: $name");
  var emailValid = validateEmail(email);
  if (emailValid != null) {
    return emailValid;
  }

  var passwordValid = validatePassword(password);
  if (passwordValid != null) {
    return passwordValid;
  }

  try {
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(email: email, password: password);
    await FirebaseFunctions.instance
        .httpsCallable("createAccount")
        .call({"name": name, "username": username});
  } on FirebaseFunctionsException catch (error) {
    log(error.toString());
    await FirebaseAuth.instance.currentUser?.delete();
    return error.message.toString();
  } on FirebaseAuthException catch (error) {
    log(error.toString());
    await FirebaseAuth.instance.currentUser?.delete();
    return error.message.toString();
  } catch (error) {
    await FirebaseAuth.instance.currentUser?.delete();
    log(error.toString(), error: error);
    return "Something went wrong...";
  }

  return null;
}
