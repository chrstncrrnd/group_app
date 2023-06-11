import 'dart:developer';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:group_app/utils/validators.dart';

Future<Map<String, dynamic>> _updateStorage(
    {required String valueName,
    required String location,
    required bool removeCurrent,
    File? fileToUpload}) async {
  var ref = FirebaseStorage.instance.ref(location);
  Map<String, dynamic> out = {};

  if (removeCurrent) {
    try {
      await ref.delete();
      out[valueName] = null;
    } catch (e) {
      log("Firebase storage error", error: e);
    }
  }
  if (fileToUpload != null) {
    await ref.putFile(fileToUpload);
    var dlUrl = await ref.getDownloadURL();
    out[valueName] = {"dlUrl": dlUrl, "location": location};
  }
  return out;
}

Future<String?> removeFollower(
    {required String userId, required String groupId}) async {
  try {
    await FirebaseFunctions.instance
        .httpsCallable("removeUserFromGroup")
        .call({"userId": userId, "groupId": groupId, "as": "follower"});
  } on FirebaseFunctionsException catch (e) {
    return e.message;
  }
  return null;
}

Future<String?> removeMember(
    {required String userId, required String groupId}) async {
  try {
    await FirebaseFunctions.instance
        .httpsCallable("removeUserFromGroup")
        .call({"userId": userId, "groupId": groupId, "as": "member"});
  } on FirebaseFunctionsException catch (e) {
    return e.message;
  }
  return null;
}

Future<String?> updateGroup(
    {File? banner,
    File? icon,
    String? groupName,
    String? description,
    bool? private,
    required bool removeBanner,
    required bool removeIcon,
    required String groupId}) async {
  Map<String, dynamic> params = {};
  if (groupName != null) {
    var groupNameInvalid = validateGroupName(groupName);
    if (groupNameInvalid != null) {
      return groupNameInvalid;
    }
    params["groupName"] = groupName;
  }

  if (private != null) {
    params["private"] = private;
  }

  if (description != null) {
    var descriptionInvalid = validateGroupDescription(description);
    if (descriptionInvalid != null) {
      return descriptionInvalid;
    }
    params["groupDescription"] = description;
  }
  String bannerLoc = "groups/$groupId/banner.jpeg";

  var bannerRes = await _updateStorage(
      valueName: "banner",
      location: bannerLoc,
      removeCurrent: removeBanner,
      fileToUpload: banner);
  params.addAll(bannerRes);

  String iconLoc = "groups/$groupId/icon.jpeg";

  var iconRes = await _updateStorage(
      valueName: "icon",
      location: iconLoc,
      removeCurrent: removeIcon,
      fileToUpload: icon);
  params.addAll(iconRes);

  if (params.isEmpty) {
    return null;
  }
  params.addAll({"groupId": groupId});
  try {
    await FirebaseFunctions.instance.httpsCallable("updateGroup").call(params);
  } on FirebaseFunctionsException catch (e) {
    log(e.message.toString(), error: e);
    return e.message;
  }
  return null;
}

Future<void> deleteGroup({required String groupId}) async {
  try {
  await FirebaseFunctions.instance
      .httpsCallable("deleteGroup")
      .call({"groupId": groupId});
  } catch (e) {
    log("FirebaseFunctions exception @ deleteGroup", error: e);
  }
}

Future<String?> createPage(String pageName, String groupId) async {
  try {
    await FirebaseFunctions.instance
        .httpsCallable("createPage")
        .call({"pageName": pageName, "groupId": groupId});
  } on FirebaseFunctionsException catch (e) {

    log("FirebaseFunctions exception @ createPage", error: e);
    return e.message;
  }
  return null;
}

Future<String?> updatePage(
    {required String pageName,
    required String pageId,
    required String groupId}) async {
  try {
    await FirebaseFunctions.instance
        .httpsCallable("updatePage")
        .call({"pageName": pageName, "pageId": pageId, "groupId": groupId});
  } on FirebaseFunctionsException catch (e) {
    log("FirebaseFunctions exception @ updatePage", error: e);
    return e.message;
  }
}
