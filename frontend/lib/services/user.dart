import 'dart:developer';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:group_app/utils/validators.dart';

import 'auth.dart';

Future<String?> updateProfile(
    {String? name,
    String? username,
    File? pfp,
    required bool removeCurrentPfp}) async {
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

  String userId = FirebaseAuth.instance.currentUser!.uid;
  String pfpLoc = "users/$userId/pfp.jpeg";

  var pfpRef = FirebaseStorage.instance.ref(pfpLoc);

  try {
    if (removeCurrentPfp) {
      await pfpRef.delete();
      params.addAll({"pfp": null});
    }
    if (pfp != null) {
      await pfpRef.putFile(pfp);
      var pfpDlUrl = await pfpRef.getDownloadURL();
      params.addAll({
        "pfp": {"dlUrl": pfpDlUrl, "location": pfpLoc}
      });
    }
  } catch (e) {
    // delete pfp if it was uploaded
    if (pfp != null) {
      var pfpRef = FirebaseStorage.instance.ref(pfpLoc);
      await pfpRef.delete();
    }
    log(e.toString(), error: e);
  }

  try {
    await FirebaseFunctions.instance
        .httpsCallable("updateProfile")
        .call(params);
  } on FirebaseFunctionsException catch (error) {
    log(error.toString());
    return error.message.toString();
  } catch (error) {
    log(error.toString(), error: error);
    return "Something went wrong...";
  }

  return null;
}
