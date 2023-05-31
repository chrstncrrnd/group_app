import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/models/current_user_private_data.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/services/current_user_provider.dart';
import 'package:group_app/services/group/group_actions.dart';
import 'package:group_app/ui/screens/home/groups/widgets/affiliated_users_view.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/interaction_button.dart';
import 'package:group_app/ui/widgets/native_context_menu.dart';
import 'package:group_app/utils/constants.dart';
import 'package:provider/provider.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key, required this.initialGroupState});
  final Group initialGroupState;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Group>(
      initialData: initialGroupState,
      stream: Group.asStream(id: initialGroupState.id),
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

        var group = snapshot.data!;
        var currentUser =
            Provider.of<CurrentUserProvider>(context).currentUser!;
        List<Widget> top = [
          header(group, context, currentUser),
          const SizedBox(
            height: 10,
          ),
          StatefulBuilder(
              builder: (ctx, stateSetter) =>
                  followJoinButtons(ctx, group, stateSetter)),
          const SizedBox(
            height: 20,
          ),
          description(context, group.description),
          AffiliatedUsersView(group: group),
          if (!userHasAccess(group, currentUser)) noAccess(context)
        ];
        return SafeArea(
            child: ListView.builder(
          itemCount: top.length,
          itemBuilder: (context, index) {
            if (index < top.length) {
              return top[index];
            } else {
              if (!userHasAccess(group, currentUser)) return null;
            }
            index -= top.length;
            return null;
          },
        ));
      },
    );
  }

  bool userHasAccess(Group group, CurrentUser currentUser) {
    return group.followers.contains(currentUser.id) ||
        group.members.contains(currentUser.id) ||
        !group.private;
  }

  Widget noAccess(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: const Center(
          child: Column(
        children: [
          Text(
            "Private group",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 8,
          ),
          Text("Follow or join this group to view posts")
        ],
      )),
    );
  }

  Widget description(BuildContext context, String? description) {
    if (description == null) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      child: Text(
        description,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget followJoinButtons(
      BuildContext context, Group group, StateSetter setState) {
    CurrentUserPrivateData privateData =
        Provider.of<CurrentUserProvider>(context).privateData!;

    Widget wrapper({required Widget child}) {
      return Flexible(
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: child,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        wrapper(
          child: InteractionButton(
            activeTitle: group.private ? "Request follow" : "Follow",
            inactiveTitle: privateData.followRequests.contains(group.id)
                ? "Requested"
                : "Unfollow",
            errorTitle: "An error occurred",
            initState: () async {
              if (group.followers.contains(privateData.id) ||
                  privateData.followRequests.contains(group.id)) {
                return InteractionButtonState.inactive;
              } else {
                return InteractionButtonState.active;
              }
            },
            onTap: (state) async {
              if (state == InteractionButtonState.active) {
                try {
                  await followGroup(group.id);
                  if (group.private) {
                    // we only need to update this because currentUser.following
                    // will will be updated server side causing a rerender
                    privateData.followRequests.add(group.id);
                    setState(() {});
                  }

                  return InteractionButtonState.inactive;
                } catch (error) {
                  log(error.toString());
                  return InteractionButtonState.error;
                }
              } else {
                try {
                  await unFollowGroup(group.id);
                  privateData.followRequests.remove(group.id);
                  setState(() {});
                  return InteractionButtonState.active;
                } catch (error) {
                  log(error.toString());
                  return InteractionButtonState.error;
                }
              }
            },
          ),
        ),
        wrapper(
          child: InteractionButton(
            activeTitle: "Request join",
            inactiveTitle: privateData.joinRequests.contains(group.id)
                ? "Requested"
                : "Leave",
            errorTitle: "An error occurred",
            initState: () async {
              if (group.members.contains(privateData.id) ||
                  privateData.joinRequests.contains(group.id)) {
                return InteractionButtonState.inactive;
              } else {
                return InteractionButtonState.active;
              }
            },
            onTap: (state) async {
              if (state == InteractionButtonState.active) {
                try {
                  await joinGroup(group.id);
                  privateData.joinRequests.add(group.id);

                  setState(() {});
                  return InteractionButtonState.inactive;
                } catch (error) {
                  log(error.toString());
                  return InteractionButtonState.error;
                }
              } else {
                try {
                  await leaveGroup(group.id);
                  privateData.joinRequests.remove(group.id);
                  setState(() {});
                  return InteractionButtonState.active;
                } catch (error) {
                  log(error.toString());
                  return InteractionButtonState.error;
                }
              }
            },
          ),
        ),
      ],
    );
  }

  Widget header(Group group, BuildContext context, CurrentUser currentUser) {
    return SizedBox(
      height: bannerHeight.toDouble(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          group.bannerDlUrl != null
              ? Image.network(
                  group.bannerDlUrl!,
                  fit: BoxFit.cover,
                )
              : /*this should change to something else ->*/ const Center(
                  child: Icon(
                    Icons.group,
                    size: 50,
                    color: Color.fromARGB(82, 255, 255, 255),
                  ),
                ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Colors.white.withOpacity(0.15))),
                    ),
                    IconButton(
                      onPressed: () => showNativeContextMenu(context, [
                        if (group.admins.contains(currentUser.id))
                          (
                            child: const Text("Edit"),
                            onPressed: () =>
                                context.push("/group/edit", extra: group)
                          ),
                        (
                          child: const Text("Share"),
                          onPressed: () => log("pressed share")
                        ),
                        (
                          child: const Text("Report"),
                          onPressed: () => log("pressed report")
                        )
                      ]),
                      icon: const Icon(Icons.menu),
                      style: ButtonStyle(
                          backgroundColor: MaterialStatePropertyAll(
                              Colors.white.withOpacity(0.15))),
                    ),
                  ],
                ),
                Row(
                  children: [
                    BasicCircleAvatar(radius: 30, child: group.icon(60)),
                    const SizedBox(
                      width: 20,
                    ),
                    Text(
                      group.name,
                      style: const TextStyle(shadows: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 20,
                          spreadRadius: 20,
                        )
                      ], fontWeight: FontWeight.bold, fontSize: 30),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
