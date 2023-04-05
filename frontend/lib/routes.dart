import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/ui/screens/auth/create_account.dart';
import 'package:group_app/ui/screens/auth/intro.dart';
import 'package:group_app/ui/screens/auth/login.dart';
import 'package:group_app/ui/screens/auth/create_profile.dart';
import 'package:group_app/ui/screens/home/home.dart';

class Routes extends ChangeNotifier {
  final List<GoRoute> _authRoutes = [
    GoRoute(
        path: "/",
        builder: (context, state) => const IntroScreen(),
        routes: [
          GoRoute(
            path: "login",
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: "create_profile",
            builder: (context, state) => const CreateProfileScreen(),
          ),
          GoRoute(
            name: "create_account",
            path: "create_account/:username",
            builder: (context, state) => CreateAccountScreen(
              username: state.params["username"]!,
              name: state.queryParams["name"],
            ),
          )
        ]),
  ];

  final List<GoRoute> _mainRoutes = [
    GoRoute(
      path: "/",
      builder: (context, state) => const HomeScreen(),
    )
  ];

  List<GoRoute> get routes =>
      FirebaseAuth.instance.currentUser != null ? _mainRoutes : _authRoutes;
}
