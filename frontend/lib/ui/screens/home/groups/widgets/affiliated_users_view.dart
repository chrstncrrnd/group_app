import 'package:flutter/material.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/user.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/suspense.dart';

enum ViewType {
  members,
  followers;

  @override
  String toString() {
    switch (this) {
      case ViewType.members:
        return "Members";
      case ViewType.followers:
        return "Followers";
    }
  }
}

class AffiliatedUsersView extends StatefulWidget {
  const AffiliatedUsersView({super.key, required this.group});

  final Group group;

  @override
  State<AffiliatedUsersView> createState() => _AffiliatedUsersViewState();
}

class _AffiliatedUsersViewState extends State<AffiliatedUsersView> {
  ViewType _viewType = ViewType.followers;

  Widget selectViewTypeButton(ViewType viewType) {
    return TextButton(
        onPressed: () {
          if (_viewType == viewType) return;
          setState(() {
            _viewType = viewType;
          });
        },
        child: Text(
          viewType.toString(),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              decoration: viewType == _viewType
                  ? TextDecoration.underline
                  : TextDecoration.none),
        ));
  }

  @override
  Widget build(BuildContext context) {
    var itemCount = _viewType == ViewType.followers
        ? widget.group.followers.length
        : widget.group.members.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            selectViewTypeButton(ViewType.followers),
            selectViewTypeButton(ViewType.members),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20)),
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: itemCount,
            itemBuilder: (context, index) {
              String userId = _viewType == ViewType.followers
                  ? widget.group.followers[index]
                  : widget.group.members[index];
              return _AffiliatedUserTile(
                userId: userId,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AffiliatedUserTile extends StatelessWidget {
  const _AffiliatedUserTile({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context) {
    return Suspense<User>(
        future: User.fromId(id: userId),
        placeholder: placeholder(),
        builder: (context, user) {
          if (user == null) {
            return const Text("Something went wrong...");
          }
          return Column(
            children: [
              BasicCircleAvatar(radius: 20, child: user.pfp(40)),
              Text(user.username)
            ],
          );
        });
  }

  Widget placeholder() {
    return const Text("loading");
  }
}
