import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> clearCache() async {
  log("Clearing cache...");
  try {
    await FirebaseFirestore.instance.clearPersistence();
  } catch (error) {
    log("Error while clearing Firestore cache: ${error.toString()}");
    return;
  }

  log("Done clearing cache");
}
