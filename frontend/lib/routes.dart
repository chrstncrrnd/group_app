import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:groopo/models/group.dart';
import 'package:groopo/models/page.dart';
import 'package:groopo/ui/animations/route_animations.dart';
import 'package:groopo/ui/screens/auth/create_account.dart';
import 'package:groopo/ui/screens/auth/intro.dart';
import 'package:groopo/ui/screens/auth/login.dart';
import 'package:groopo/ui/screens/auth/create_profile.dart';
import 'package:groopo/ui/screens/home/groups/affiliated_users.dart';
import 'package:groopo/ui/screens/home/groups/edit_group.dart';
import 'package:groopo/ui/screens/home/groups/group_profile.dart';
import 'package:groopo/ui/screens/home/groups/new_group.dart';
import 'package:groopo/ui/screens/home/feed.dart';
import 'package:groopo/ui/screens/home/groups/groups.dart';
import 'package:groopo/ui/screens/home/groups/pages/page/group_page.dart';
import 'package:groopo/ui/screens/home/groups/pages/page/new_post/submit_new_post.dart';
import 'package:groopo/ui/screens/home/groups/pages/page/new_post/take_new_post.dart';
import 'package:groopo/ui/screens/home/groups/pages/page/posts/post_modal.dart';
import 'package:groopo/ui/screens/home/home.dart';
import 'package:groopo/ui/screens/home/new_post/new_post.dart';
import 'package:groopo/ui/screens/home/notifications/group_notifications_screen.dart';
import 'package:groopo/ui/screens/home/notifications/notifications.dart';
import 'package:groopo/ui/screens/home/profile.dart';
import 'package:groopo/ui/screens/home/search/search.dart';
import 'package:groopo/ui/screens/home/settings/profile_settings.dart';
import 'package:groopo/ui/screens/home/settings/settings_directory.dart';
import 'package:groopo/ui/screens/home/user/user_affiliated_groups.dart';
import 'package:groopo/ui/screens/home/user/user_profile.dart';
import 'package:groopo/models/user.dart' as groopo_user;

class Routes extends ChangeNotifier {
  Routes({this.signedIn = false}) {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      signedIn = user != null;

      notifyListeners();
    });

    _authRouter = GoRouter(
        redirect: (context, state) {
          if (state.path == "/") {
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
              username: state.pathParameters["username"]!,
              name: state.uri.queryParameters["name"],
            ),
          )
        ]);

    _mainRouter = GoRouter(
        redirect: (context, state) {
          if (state.path == "/") {
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
                      noTransition(context, state, const GroupsScreen()),
                ),
                GoRoute(
                    path: "/new_post",
                    pageBuilder: (context, state) =>
                        noTransition(context, state, const NewPostScreen())),
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
                  path: "/group",
                  builder: (context, state) =>
                      GroupScreen(initialGroupState: state.extra! as Group),
                    routes: [
                      GoRoute(
                        path: "edit",
                        builder: (context, state) => EditGroupScreen(
                            initialGroupState: state.extra! as Group),

                      ),
                      GoRoute(
                          path: "followers",
                          builder: (context, state) => AffiliatedUsersScreen(
                                extra:
                                    state.extra as AffiliatedUsersScreenExtra,
                              )),
                      GoRoute(
                          path: "members",
                          builder: (context, state) => AffiliatedUsersScreen(
                                extra:
                                    state.extra as AffiliatedUsersScreenExtra,
                              )),
                      GoRoute(
                        path: "page",
                        builder: (context, state) => GroupPageScreen(
                          extra: state.extra as GroupPageExtra,
                        ),
                          routes: [
                            GoRoute(
                              path: "contributors",
                              builder: (context, state) =>
                                  AffiliatedUsersScreen(
                                      extra: state.extra
                                          as AffiliatedUsersScreenExtra),
                            )
                          ]
                      )
                    ]
                ),
                GoRoute(
                    path: "/user",
                    builder: (context, state) => UserProfileScreen(
                        initialUserState: state.extra! as groopo_user.User),
                    routes: [
                      GoRoute(
                        path: "following",
                        builder: (context, state) => UserAffiliatedGroups(
                          type: UserAffiliatedGroupsType.following,
                          user: state.extra! as groopo_user.User,
                        ),
                      ),
                      GoRoute(
                          path: "member_of",
                          builder: (context, state) => UserAffiliatedGroups(
                                type: UserAffiliatedGroupsType.memberOf,
                                user: state.extra! as groopo_user.User,
                              ))
                    ]),
                GoRoute(
                  path: "/notifications",
                  builder: (context, state) => const NotificationsScreen(),
                    routes: [
                      GoRoute(
                        path: "group",
                        builder: (context, state) => GroupNotificationScreen(
                            group: state.extra! as Group),
                      )
                    ]
                )
              ]),
          GoRoute(
            parentNavigatorKey: _mainRootNavigatorKey,
            path: "/new_group",
            builder: (context, _) => const NewGroupScreen(),
          ),
          GoRoute(
              parentNavigatorKey: _mainRootNavigatorKey,
            path: "/take_new_post",
              builder: (context, state) =>
                TakeNewPostScreen(inPage: state.extra as GroupPage),
          ),
          GoRoute(
            parentNavigatorKey: _mainRootNavigatorKey,
            path: "/submit_new_post",
            builder: (context, state) =>
                SubmitNewPostScreen(extra: state.extra as SubmitNewPostExtra),
          ),

          GoRoute(
              path: "/post_modal",
              parentNavigatorKey: _mainRootNavigatorKey,
              builder: ((context, state) => PostModalScreen(
                    extra: state.extra as PostModalScreenExtra,
                  ))
              
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
