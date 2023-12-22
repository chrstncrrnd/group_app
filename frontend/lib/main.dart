import 'dart:developer';

import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:group_app/firebase_options.dart';
import 'package:group_app/routes.dart';
import 'package:group_app/services/current_user_provider.dart';
import 'package:group_app/utils/theme.dart';
import 'package:provider/provider.dart';

List<CameraDescription> cameras = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } catch (e) {
    log("An error occurred fetching available cameras", error: e);
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (kDebugMode) {
    log("Using Firebase Local Emulators");
    await FirebaseAuth.instance.useAuthEmulator("localhost", 9099);
    FirebaseFunctions.instance.useFunctionsEmulator("localhost", 5001);
    FirebaseFirestore.instance.useFirestoreEmulator("localhost", 8080);
    FirebaseStorage.instance.useStorageEmulator("localhost", 9199);
  }
  runApp(GroupApp());
}

class GroupApp extends StatelessWidget {
  GroupApp({super.key});

  final Routes _routes = Routes();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<Routes>.value(value: _routes),
          ChangeNotifierProvider<CurrentUserProvider>(
            create: (ctx) => CurrentUserProvider(),
            lazy: false,
          )
        ],
        builder: (ctx, child) => MaterialApp.router(
              debugShowCheckedModeBanner: false,
              routerConfig: Provider.of<Routes>(ctx).router,
              theme: theme,
            ));
  }
}
