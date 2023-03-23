import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:group_app/firebase_options.dart';
import 'package:group_app/ui/screens/auth/intro.dart';
import 'package:group_app/ui/screens/home.dart';
import 'package:group_app/utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await FirebaseAuth.instance.useAuthEmulator("localhost", 9099);
  }

  runApp(const GroupApp());
}

class GroupApp extends StatelessWidget {
  const GroupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: theme,
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                  body: Center(child: CircularProgressIndicator.adaptive()));
            }
            if (snapshot.hasError) {
              // TODO: error text (with widget)
            }
            // user logged in
            if (snapshot.hasData) {
              return const HomeScreen();
            } else {
              return const IntroScreen();
            }
          },
        ));
  }
}
