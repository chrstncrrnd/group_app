import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/ui/animations/route_animations.dart';
import 'package:group_app/ui/screens/auth/create_account.dart';
import 'package:group_app/ui/screens/auth/intro.dart';
import 'package:group_app/ui/screens/auth/login.dart';
import 'package:group_app/ui/screens/auth/create_profile.dart';
import 'package:group_app/ui/screens/home/feed.dart';
import 'package:group_app/ui/screens/home/groups.dart';
import 'package:group_app/ui/screens/home/home.dart';
import 'package:group_app/ui/screens/home/new_post.dart';
import 'package:group_app/ui/screens/home/profile.dart';
import 'package:group_app/ui/screens/home/search.dart';

class Routes {
  final List<RouteBase> _authRoutes = [
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

  final List<RouteBase> _mainRoutes = [
    ShellRoute(
        builder: (context, GoRouterState state, Widget child) => HomeScreen(
              state: state,
              child: child,
            ),
        routes: [
          GoRoute(
            path: "/",
            pageBuilder: (context, state) =>
                noTransition(context, state, const FeedScreen()),
          ),
          GoRoute(
            path: "/groups",
            pageBuilder: (context, state) =>
                noTransition(context, state, const GroupsScreens()),
          ),
          GoRoute(
            path: "/new_post",
            pageBuilder: (context, state) =>
                noTransition(context, state, const NewPostScreen()),
          ),
          GoRoute(
            path: "/search",
            pageBuilder: (context, state) =>
                noTransition(context, state, const SearchScreen()),
          ),
          GoRoute(
            path: "/profile",
            pageBuilder: (context, state) =>
                noTransition(context, state, const ProfileScreen()),
          )
        ]),
  ];

  List<RouteBase> routes(bool signedIn) => signedIn ? _mainRoutes : _authRoutes;
}
