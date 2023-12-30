import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:groopo/models/user.dart';
import 'package:groopo/services/current_user_provider.dart';
import 'package:groopo/ui/widgets/basic_circle_avatar.dart';
import 'package:groopo/ui/widgets/async/shimmer_loading_indicator.dart';
import 'package:provider/provider.dart';

import '../../widgets/stat.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final _nameTextStyle =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 28);

  // more or less mimics what the actual ui looks like
  Widget buildPlaceholder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const ShimmerLoadingIndicator(
        child: Text(
          "-------------------",
          style: TextStyle(color: Colors.transparent),
        ),
      )),
      body: Center(
          child: Column(
        children: [
          ShimmerLoadingIndicator(
            width: 120,
            height: 120,
            borderRadius: BorderRadius.circular(100),
          ),
          const SizedBox(
            height: 20,
          ),
          ShimmerLoadingIndicator(
            child: Text(
              "-------------------",
              style: _nameTextStyle.copyWith(color: Colors.transparent),
            ),
          )
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    var currentUser = Provider.of<CurrentUserProvider>(context).currentUser;
    if (currentUser == null) {
      return const Center(
        child: Text("An error occurred"),
      );
    }
    return Scaffold(
        appBar: AppBar(
          title: AutoSizeText(
            "@${currentUser.username}",
            maxLines: 1,
          ),
          actions: [
            IconButton(
                onPressed: () => context.push("/settings"),
                icon: const Icon(Icons.settings_outlined))
          ],
        ),
        body: Center(
            child: Column(
          children: [
            BasicCircleAvatar(
              radius: 50,
              child: currentUser.pfp(100),
            ),
            const SizedBox(
              height: 20,
            ),
            if (currentUser.name != null)
              AutoSizeText(
                currentUser.name!,
                maxLines: 1,
                style: _nameTextStyle,
              ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  StatWidget(
                      name: "Member of",
                      value: currentUser.memberOf.length,
                      onPressed: () => User.fromId(id: currentUser.id).then(
                          (user) =>
                              context.push("/user/member_of", extra: user))),
                  StatWidget(
                      name: "Following",
                      value: currentUser.following.length,
                      onPressed: () => User.fromId(id: currentUser.id).then(
                          (user) =>
                              context.push("/user/following", extra: user))),
                ],
              ),
            )
          ],
        )));
  }
}
