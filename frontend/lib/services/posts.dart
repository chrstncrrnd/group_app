import 'dart:developer';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:groopo/models/page.dart';
import 'package:groopo/utils/rand_str.dart';
import 'package:image/image.dart';

Future<String?> createPost(
    {required GroupPage page,
    required File file,
    required String caption}) async {
  var params = {};

  Image? image = await decodeImageFile(file.path);
  if (image == null) {
    return "Unable to decode image";
  }

  // Max size of 1080 x 1920
  Image resized = copyResize(image, width: 1080);

  // If for some reason the file is over 20mb, don't post it
  if (resized.length > 20000000) {
    return "Unable to post image. Image was too big";
  }

  await encodeJpgFile(file.path, resized, quality: 75);

  String id = getRandomString(20);

  String postLoc = "/groups/${page.groupId}/pages/${page.id}/$id.jpeg";

  var ref = FirebaseStorage.instance.ref(postLoc);

  await ref.putFile(file);
  String dlUrl = await ref.getDownloadURL();

  params.addAll({"dlUrl": dlUrl, "location": postLoc});
  try {
    await FirebaseFunctions.instance.httpsCallable("createPost").call({
      "dlUrl": dlUrl,
      "location": postLoc,
      "id": id,
      "groupId": page.groupId,
      "pageId": page.id,
      "caption": caption
    });
  } on FirebaseFunctionsException catch (e) {
    log("An error occurred while creating post", error: e);
    return e.message;
  }

  return null;
}

Future<String?> deletePost(String groupId, String pageId, String postId) async {
  try {
    await FirebaseFunctions.instance.httpsCallable("deletePost").call({
      "groupId": groupId,
      "pageId": pageId,
      "postId": postId,
    });
  } on FirebaseFunctionsException catch (e) {
    log("An error occurred while deleting post", error: e);
    return e.message;
  }

  return null;
}

Future<String?> likePost(String groupId, String pageId, String postId) async {
  try {
    await FirebaseFunctions.instance.httpsCallable("likePost").call({
      "groupId": groupId,
      "pageId": pageId,
      "postId": postId,
    });
  } on FirebaseFunctionsException catch (e) {
    log("An error occurred while liking to a post", error: e);
    return e.message;
  }
  return null;
}

Future<String?> unlikePost(String groupId, String pageId, String postId) async {
  try {
    await FirebaseFunctions.instance.httpsCallable("unlikePost").call({
      "groupId": groupId,
      "pageId": pageId,
      "postId": postId,
    });
  } on FirebaseFunctionsException catch (e) {
    log("An error occurred while un-liking to a post", error: e);
    return e.message;
  }
  return null;
}

Future<String?> addComment(
    String groupId, String pageId, String postId, String comment) async {
  try {
    await FirebaseFunctions.instance.httpsCallable("addComment").call({
      "groupId": groupId,
      "pageId": pageId,
      "postId": postId,
      "comment": comment.trim()
    });
  } on FirebaseFunctionsException catch (e) {
    log("An error occurred while adding a comment", error: e);
    return e.message;
  }
  return null;
}
