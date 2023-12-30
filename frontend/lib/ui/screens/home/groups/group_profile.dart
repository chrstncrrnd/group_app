import 'dart:developer';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:groopo/models/current_user.dart';
import 'package:groopo/models/current_user_private_data.dart';
import 'package:groopo/models/group.dart';
import 'package:groopo/services/current_user_provider.dart';
import 'package:groopo/services/group/group_actions.dart';
import 'package:groopo/services/group/group_update.dart';
import 'package:groopo/ui/screens/home/groups/affiliated_users.dart';
import 'package:groopo/ui/screens/home/groups/pages/pages_grid.dart';
import 'package:groopo/ui/widgets/async/suspense.dart';
import 'package:groopo/ui/widgets/basic_circle_avatar.dart';
import 'package:groopo/ui/widgets/buttons/interaction_button.dart';
import 'package:groopo/ui/widgets/dialogs/context_menu.dart';
import 'package:groopo/ui/widgets/stat.dart';
import 'package:groopo/utils/constants.dart';
import 'package:provider/provider.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key, required this.initialGroupState});
  final Group initialGroupState;

  @override
  Widget build(BuildContext context) {
    var currentUser = Provider.of<CurrentUserProvider>(context).currentUser!;
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
        return SafeArea(
          child: Container(
            color: Colors.black,
            child: SingleChildScrollView(
              child: Column(children: [
                _header(group, context, currentUser),
                const SizedBox(
                  height: 10,
                ),
                _description(context, group.description),
                _affiliatedUsersCount(context, group, currentUser),
                const SizedBox(
                  height: 10,
                ),
                StatefulBuilder(
                    builder: (ctx, stateSetter) => _followJoinButtons(
                        ctx, group, stateSetter, currentUser)),
                if (!_userHasAccess(group, currentUser))
                  _noAccess(context)
                else
                  Provider.value(
                      value: group,
                      child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15, vertical: 20),
                          child: PagesGrid())),
              ]),
            ),
          ),
        );
      },
    );
  }

  Widget _affiliatedUsersCount(
      BuildContext context, Group group, CurrentUser currentUser) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        StatWidget(
            value: group.followers.length,
            name: "Followers",
            onPressed: () => context.push("/group/followers",
                extra: AffiliatedUsersScreenExtra(
                  users: group.followers,
                  title: "Followers",
                  isAdmin: group.admins.contains(currentUser.id),
                  onRemove: (userId) async {
                    return await removeFollower(
                        userId: userId, groupId: group.id);
                  },
                ))),
        StatWidget(
            value: group.members.length,
            name: "Members",
            onPressed: () => context.push("/group/followers",
                extra: AffiliatedUsersScreenExtra(
                  users: group.members,
                  title: "Members",
                  isAdmin: group.admins.contains(currentUser.id),
                  onRemove: (userId) async {
                    return await removeMember(
                        userId: userId, groupId: group.id);
                  },
                )))
      ],
    );
  }

  bool _userHasAccess(Group group, CurrentUser currentUser) {
    return group.followers.contains(currentUser.id) ||
        group.members.contains(currentUser.id) ||
        !group.private;
  }

  Widget _noAccess(BuildContext context) {
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

  Widget _description(BuildContext context, String? description) {
    if (description == null) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
      child: Text(
        description,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _followJoinButtons(BuildContext context, Group group,
      StateSetter setState, CurrentUser currentUser) {
    Widget wrapper({required Widget child}) {
      return Flexible(
        flex: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: child,
        ),
      );
    }

    return Suspense<CurrentUserPrivateData>(
        future: CurrentUserPrivateData.getData(userId: currentUser.id),
        builder: (context, privateData) {
          if (privateData == null) {
            return Container();
          }
          // this is really messy, but it works, DO NOT TOUCH!!!!!
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
                      // you cannot leave a group you are an admin in
                      if (group.admins
                          .contains(FirebaseAuth.instance.currentUser!.uid)) {
                        return state;
                      }
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
        });
  }

  Widget _header(Group group, BuildContext context, CurrentUser currentUser) {
    const iconRadius = 30.0;
    return Container(
      decoration: const BoxDecoration(color: Colors.black),
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
                    if (group.admins.contains(currentUser.id))
                      IconButton(
                        onPressed: () => showContextMenu(
                          context: context,
                          items: [
                            if (group.admins.contains(currentUser.id))
                              (
                                child: const Text("Edit"),
                                onPressed: () =>
                                    context.push("/group/edit", extra: group),
                                icon: const Icon(Icons.edit)
                              ),
                            // this still needs to be done with deep linking
                            // (
                            //   child: const Text("Share"),
                            //     onPressed: () => log("pressed share"),
                            //     icon: const Icon(Icons.ios_share_rounded)
                            // )
                          ],
                          position: RelativeRect.fromDirectional(
                              top: 0,
                              end: 0,
                              textDirection: TextDirection.ltr,
                              start: 1,
                              bottom: 1),
                        ),
                        icon: const Icon(Icons.more_horiz),
                        style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                Colors.white.withOpacity(0.15))),
                      ),
                  ],
                ),
                Row(
                  children: [
                    BasicCircleAvatar(
                        radius: iconRadius, child: group.icon(iconRadius * 2)),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: AutoSizeText(
                        group.name,
                        maxLines: 1,
                        style: const TextStyle(shadows: [
                          BoxShadow(
                            color: Colors.black,
                            blurRadius: 20,
                            spreadRadius: 20,
                          )
                        ], fontWeight: FontWeight.bold, fontSize: 30),
                      ),
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
