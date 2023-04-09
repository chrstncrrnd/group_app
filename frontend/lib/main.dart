import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:group_app/firebase_options.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/routes.dart';
import 'package:group_app/utils/go_router_change_notifier.dart';
import 'package:group_app/utils/theme.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseAuth.instance.useAuthEmulator("localhost", 9099);
    FirebaseFunctions.instance.useFunctionsEmulator("localhost", 5001);
    FirebaseFirestore.instance.useFirestoreEmulator("localhost", 8080);
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
          ChangeNotifierProvider<GoRouterChangeNotifier>(
              create: (ctx) => GoRouterChangeNotifier(routes: Routes())),
          StreamProvider<CurrentUser?>(
            create: (ctx) {
              if (FirebaseAuth.instance.currentUser != null) {
                return CurrentUser.asStream(
                    FirebaseAuth.instance.currentUser!.uid);
              }
              return null;
            },
            initialData: null,
          )
        ],
        builder: (ctx, child) => MaterialApp.router(
              routerConfig: Provider.of<GoRouterChangeNotifier>(ctx).router,
              theme: theme,
            ));
  }
}
