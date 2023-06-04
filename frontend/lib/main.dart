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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseAuth.instance.useAuthEmulator("192.168.0.17", 9099);
    FirebaseFunctions.instance.useFunctionsEmulator("192.168.0.17", 5001);
    FirebaseFirestore.instance.useFirestoreEmulator("192.168.0.17", 8080);
    FirebaseStorage.instance.useStorageEmulator("192.168.0.17", 9199);
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
