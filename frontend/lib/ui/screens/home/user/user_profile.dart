import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/user.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/fallback_text.dart';
import 'package:group_app/ui/widgets/stat.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key, required this.initialUserState});

  final User initialUserState;



  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User>(
      initialData: initialUserState,
      stream: User.asStream(id: initialUserState.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }
        if (snapshot.hasError || snapshot.data == null) {
          return const Center(
            child: Text("Something went wrong..."),
          );
        }

        User user = snapshot.data!;
        const double avatarSize = 100;
        return Scaffold(
          appBar: AppBar(
            title: FbText(
              user.name,
              fallbackText: "",
            ),
            centerTitle: true,
          ),
          body: Center(
            child: Column(children: [
              BasicCircleAvatar(
                  radius: avatarSize / 2, child: user.pfp(avatarSize)),
              AutoSizeText(
                "@${user.username}",
                maxLines: 1,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    StatWidget(
                      name: "Member of",
                      value: user.memberOf.length,
                      onPressed: () =>
                          context.push("/user/member_of", extra: user),
                    ),
                    StatWidget(
                      name: "Following",
                      value: user.following.length,
                      onPressed: () =>
                          context.push("/user/following", extra: user),
                    ),
                  ],
                ),
              )
            ]),
          ),
        );
      },
    );
  }
}
