import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/user.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/fallback_text.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key, required this.initialUserState});

  final User initialUserState;

  Widget _statWidget({required String stat, required int value}) {
    return Expanded(
        flex: 1,
        child: Column(
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade100,
                  fontSize: 18),
            ),
            Text(
              stat,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ));
  }

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
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => context.pop(),
            ),
          ),
          body: Center(
            child: Column(children: [
              BasicCircleAvatar(
                  radius: avatarSize / 2, child: user.pfp(avatarSize)),
              Text(
                "@${user.username}",
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: Row(
                  children: [
                    _statWidget(stat: "Member of", value: user.memberOf.length),
                    _statWidget(
                        stat: "Following", value: user.following.length),
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