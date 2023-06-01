import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/user.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/shimmer_loading_indicator.dart';
import 'package:group_app/ui/widgets/suspense.dart';
import 'package:group_app/utils/max.dart';

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

  int getNumPeople(vt) => vt == ViewType.followers
      ? widget.group.followers.length
      : widget.group.members.length;

  Widget selectViewTypeButton(ViewType viewType) {
    bool currentlySelected = _viewType == viewType;

    return TextButton(
        onPressed: () {
          if (currentlySelected) return;
          setState(() {
            _viewType = viewType;
          });
        },
        child: Text(
          "${viewType.toString()} ${getNumPeople(viewType)}",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: currentlySelected
                  ? Colors.grey.shade300
                  : Colors.grey.shade600),
        ));
  }

  @override
  Widget build(BuildContext context) {
    var itemCount = _viewType == ViewType.followers
        ? widget.group.followers.length
        : widget.group.members.length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              selectViewTypeButton(ViewType.followers),
              selectViewTypeButton(ViewType.members),
            ],
          ),
          Container(
            width: Max.width(context),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20)),
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: itemCount,
              itemBuilder: (context, index) {
                String userId = _viewType == ViewType.followers
                    ? widget.group.followers[index]
                    : widget.group.members[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _AffiliatedUserTile(
                    userId: userId,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AffiliatedUserTile extends StatelessWidget {
  const _AffiliatedUserTile({required this.userId});

  final String userId;
  final double radius = 20;
  final TextStyle primaryText = const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      overflow: TextOverflow.ellipsis,
      fontSize: 14);

  final TextStyle secondaryText = const TextStyle(
      color: Colors.grey, overflow: TextOverflow.ellipsis, fontSize: 11);

  @override
  Widget build(BuildContext context) {
    return Suspense<User>(
        future: User.fromId(id: userId),
        placeholder: placeholder(),
        builder: (context, user) {
          if (user == null) {
            return const Text("Something went wrong...");
          }
          return GestureDetector(
            onTap: () => context.push("/user", extra: user),
            child: Column(
              children: [
                BasicCircleAvatar(radius: radius, child: user.pfp(radius * 2)),
                const SizedBox(
                  height: 2,
                ),
                if (user.isNamed) ...[
                  Text(
                    user.name!,
                    style: primaryText,
                  ),
                  Text(
                    user.username,
                    style: secondaryText,
                  )
                ] else
                  Text(
                    user.username,
                    style: primaryText,
                  )
              ],
            ),
          );
        });
  }

  Widget placeholder() {
    return Column(
      children: [
        BasicCircleAvatar(
            radius: radius,
            child: ShimmerLoadingIndicator(
                borderRadius: BorderRadius.circular(radius / 2))),
        const SizedBox(
          height: 2,
        ),
        const ShimmerLoadingIndicator(
          child: Text(
            "placeholder",
            style: TextStyle(color: Colors.transparent),
          ),
        )
      ],
    );
  }
}
