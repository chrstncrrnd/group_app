import 'dart:developer';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:groopo/utils/rand_str.dart';
import 'package:groopo/utils/validators.dart';

/// Returns a with an error if something went wrong
Future<String?> createGroup(
    {required String? name, String? description, File? icon}) async {
  final String id = getRandomString(24);

  var nameValid = validateGroupName(name);
  if (nameValid != null) {
    return nameValid;
  }

  var descriptionValid = validateGroupDescription(description);
  if (descriptionValid != null) {
    return descriptionValid;
  }

  try {
    Map<String, dynamic> params = {"groupName": name, "id": id};

    if (icon != null) {
      String iconLoc = "groups/$id/icon.jpeg";

      var iconRef = FirebaseStorage.instance.ref(iconLoc);
      await iconRef.putFile(icon);
      String iconDlUrl = await iconRef.getDownloadURL();
      params.addAll({
        "icon": {"location": iconLoc, "dlUrl": iconDlUrl}
      });
    }

    if (description != null) {
      params.addAll({"groupDescription": description});
    }
    await FirebaseFunctions.instance.httpsCallable("createGroup").call(params);
  } on FirebaseFunctionsException catch (error) {
    log(error.toString());
    return error.message.toString();
  } catch (error) {
    log(error.toString(), error: error);
    return "Something went wrong...";
  }
  return null;
}
