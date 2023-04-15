import 'dart:developer';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:group_app/utils/validators.dart';

/// Returns a with an error if something went wrong
Future<String?> createGroup(
    {required String? name, String? description}) async {
  var nameValid = validateGroupName(name);
  if (nameValid != null) {
    return nameValid;
  }

  var descriptionValid = validateGroupDescription(description);
  if (descriptionValid != null) {
    return descriptionValid;
  }

  try {
    var params = {"groupName": name};
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
