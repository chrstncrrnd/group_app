import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Page<dynamic> noTransition(
    BuildContext context, GoRouterState goRouterState, Widget page) {
  return NoTransitionPage(key: goRouterState.pageKey, child: page);
}
