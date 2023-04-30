import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/ui/animations/route_animations.dart';
import 'package:group_app/ui/screens/auth/create_account.dart';
import 'package:group_app/ui/screens/auth/intro.dart';
import 'package:group_app/ui/screens/auth/login.dart';
import 'package:group_app/ui/screens/auth/create_profile.dart';
import 'package:group_app/ui/screens/home/groups/archived_groups.dart';
import 'package:group_app/ui/screens/home/groups/new_group.dart';
import 'package:group_app/ui/screens/home/feed.dart';
import 'package:group_app/ui/screens/home/groups/groups.dart';
import 'package:group_app/ui/screens/home/home.dart';
import 'package:group_app/ui/screens/home/new_post.dart';
import 'package:group_app/ui/screens/home/profile.dart';
import 'package:group_app/ui/screens/home/search.dart';
import 'package:group_app/ui/screens/home/settings/profile_settings.dart';
import 'package:group_app/ui/screens/home/settings/settings_directory.dart';

class Routes extends ChangeNotifier {
  Routes({this.signedIn = false}) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      signedIn = user != null;

      notifyListeners();
    });

    _authRouter = GoRouter(
        redirect: (context, state) {
          if (state.location == "/") {
            return "/intro";
          }
          return null;
        },
        initialLocation: "/intro",
        routes: [
          GoRoute(
            path: "/intro",
            builder: (context, state) => const IntroScreen(),
          ),
          GoRoute(
            path: "/login",
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: "/create_profile",
            builder: (context, state) => const CreateProfileScreen(),
          ),
          GoRoute(
            name: "create_account",
            path: "/create_account/:username",
            builder: (context, state) => CreateAccountScreen(
              username: state.params["username"]!,
              name: state.queryParams["name"],
            ),
          )
        ]);

    _mainRouter = GoRouter(
        redirect: (context, state) {
          if (state.location == "/") {
            return "/feed";
          }
          return null;
        },
        navigatorKey: _mainRootNavigatorKey,
        initialLocation: "/feed",
        routes: [
          ShellRoute(
              builder: (context, GoRouterState state, Widget child) =>
                  HomeScreen(
                    state: state,
                    child: child,
                  ),
              routes: [
                GoRoute(
                  path: "/feed",
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
                ),
                GoRoute(
                    path: "/settings",
                    builder: (context, state) => const SettingsDirectoryPage(),
                    routes: [
                      GoRoute(
                        path: "profile_settings",
                        builder: (context, state) =>
                            const ProfileSettingsScreen(),
                      )
                    ]),
                GoRoute(
                  path: "/archived_groups",
                  builder: (context, state) => const ArchivedGroupsScreen(),
                )
              ]),
          GoRoute(
            parentNavigatorKey: _mainRootNavigatorKey,
            path: "/new_group",
            builder: (context, _) => const NewGroupScreen(),
          )
        ]);
  }

  final GlobalKey<NavigatorState> _mainRootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'mainRoot');

  bool signedIn;

  late final GoRouter _authRouter;
  late final GoRouter _mainRouter;

  GoRouter get router => signedIn ? _mainRouter : _authRouter;
}
