import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/services/group_actions.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/interaction_button.dart';
import 'package:provider/provider.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key, required this.initialGroupState});
  final Group initialGroupState;

  @override
  Widget build(BuildContext context) {
    CurrentUser currentUser = Provider.of<CurrentUser>(context);
    return StreamBuilder<Group>(
      initialData: initialGroupState,
      stream: FirebaseFirestore.instance
          .collection("groups")
          .doc(initialGroupState.id)
          .snapshots()
          .map((event) =>
              Group.fromJson(json: event.data()!, id: initialGroupState.id)),
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
        List<Widget> top = [
          header(group, context),
          const SizedBox(
            height: 10,
          ),
          followJoinButtons(context, group, currentUser),
        ];
        return SafeArea(
            child: ListView.builder(
          itemCount: top.length,
          itemBuilder: (context, index) {
            if (index < top.length) {
              return top[index];
            }
            index -= top.length;
          },
        ));
      },
    );
  }

  Widget followJoinButtons(
      BuildContext context, Group group, CurrentUser currentUser) {
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
            activeTitle: "Follow",
            inactiveTitle: "Unfollow",
            errorTitle: "An error occurred",
            initState: () async {
              if (group.followers.contains(currentUser.id)) {
                return InteractionButtonState.inactive;
              } else {
                return InteractionButtonState.active;
              }
            },
            onTap: (state) async {
              if (state == InteractionButtonState.active) {
                try {
                  await followGroup(group.id);
                  return InteractionButtonState.inactive;
                } catch (error) {
                  log(error.toString());
                  return InteractionButtonState.error;
                }
              } else {
                try {
                  await unFollowGroup(group.id);
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
            activeTitle: "Join",
            inactiveTitle: "Leave",
            errorTitle: "An error occurred",
            initState: () async {
              if (group.members.contains(currentUser.id)) {
                return InteractionButtonState.inactive;
              } else {
                return InteractionButtonState.active;
              }
            },
            onTap: (state) async {
              if (state == InteractionButtonState.active) {
                try {
                  await joinGroup(group.id);
                  return InteractionButtonState.inactive;
                } catch (error) {
                  log(error.toString());
                  return InteractionButtonState.error;
                }
              } else {
                try {
                  await leaveGroup(group.id);
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

  Widget header(Group group, BuildContext context) {
    return SizedBox(
      height: 300,
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
                      onPressed: () => print("show the menu"),
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
