// Services to use for auth such as logging the user in and out,
// creating a new account, dealing with profile and stuff like that

// Returns null if successful, otherwise string with what went wrong
import 'dart:developer';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:group_app/utils/validators.dart';

import '../utils/rand_str.dart';

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

Future<String?> updateProfile(
    {String? name, String? username, File? pfp, bool? removeCurrentPfp}) async {
  var params = {};
  if (name != null) {
    var nameValid = validateName(name);
    if (nameValid != null) {
      return nameValid;
    }
    params["name"] = name;
  }

  if (username != null) {
    var usernameValid = validateUsername(username);
    if (usernameValid != null) {
      return usernameValid;
    }
    // check if the username is available
    var available = await usernameAvailable(username);
    if (available != null) {
      return available;
    }
    params["username"] = username;
  }

  if (removeCurrentPfp != null) {
    params["removeCurrentPfp"] = removeCurrentPfp;
  }

  String pfpId = getRandomString(20);
  String pfpLoc = "profilePictures/$pfpId.jpeg";
  try {
    if (pfp != null) {
      var pfpRef = FirebaseStorage.instance.ref(pfpLoc);
      await pfpRef.putFile(pfp);
      String pfpDlUrl = await pfpRef.getDownloadURL();
      params.addAll({"pfpLocation": pfpLoc, "pfpDlUrl": pfpDlUrl});
    }

    log(params.toString());
    // don't bother if there isn't anything to change
    if (params.isEmpty) {
      return null;
    }

    await FirebaseFunctions.instance
        .httpsCallable("updateProfile")
        .call(params);
  } on FirebaseFunctionsException catch (error) {
    log(error.toString());
    // delete pfp if it was uploaded
    if (pfp != null) {
      var pfpRef = FirebaseStorage.instance.ref(pfpLoc);
      await pfpRef.delete();
    }
    return error.message.toString();
  } catch (error) {
    log(error.toString(), error: error);
    return "Something went wrong...";
  }
  return null;
}
