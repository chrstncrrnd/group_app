import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/interaction_button.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key, required this.initialGroupState});
  final Group initialGroupState;

  @override
  Widget build(BuildContext context) {
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
          followJoinButtons(context)
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

  Widget followJoinButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        Flexible(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: InteractionButton(
                title: "Follow",
              ),
            )),
        Flexible(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15.0),
              child: InteractionButton(
                title: "Join",
              ),
            )),
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
