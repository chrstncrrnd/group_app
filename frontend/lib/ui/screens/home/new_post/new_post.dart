import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/models/page.dart';
import 'package:group_app/services/current_user_provider.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/firestore_views/paginated/list_view.dart';
import 'package:provider/provider.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  GroupPage? selectedPage;

  Widget selectedIcon(bool selected) {
    const size = 16.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? Colors.grey.shade300 : Colors.grey.shade800),
      child: selected
          ? Icon(
              Icons.check_rounded,
              color: Colors.grey.shade800,
              size: size,
            )
          : null,
    );
  }

  Widget pageTile(context, item) {
    final GroupPage page = GroupPage.fromJson(
        json: item.data() as Map<String, dynamic>, id: item.id);

    var thisSelected = selectedPage?.id == page.id;

    return GestureDetector(
      onTap: () => setState(() {
        if (selectedPage?.id == page.id) {
          selectedPage = null;
        } else {
          selectedPage = page;
        }
      }),
      child: Container(
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: thisSelected ? Colors.grey.shade800 : Colors.grey.shade900,
            borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            selectedIcon(thisSelected),
            const SizedBox(
              width: 5,
            ),
            Text(page.name)
          ],
        ),
      ),
    );
  }

  Widget nextButton(BuildContext context) {
    var validState = selectedPage != null;

    var mainColor = validState ? Colors.black : Colors.grey.shade500;

    var bgColor = validState ? Colors.white : Colors.grey.shade300;

    void navigate() {
      if (!validState) {
        return;
      }
      context.push("/take_new_post", extra: selectedPage!);
    }

    return TextButton.icon(
      style: ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(bgColor),
      ),
      onPressed: navigate,
      icon: Icon(
        Icons.arrow_forward_ios_rounded,
        color: mainColor,
      ),
      label: Text(
        "Next",
        style: TextStyle(color: mainColor, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    CurrentUser? currentUser =
        Provider.of<CurrentUserProvider>(context).currentUser;

    if (currentUser == null) {
      log("Error in new post screen: current user is null");
      return const Center(
        child: Text("Something went wrong..."),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Where do you want to post?",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: nextButton(context),
      body: PaginatedListView(
        ifEmpty: const Center(
          child: Text("Join a group to post"),
        ),
        shrinkWrap: false,
        pullToRefresh: true,
        query: FirebaseFirestore.instance
            .collection("groups")
            .where("members", arrayContains: currentUser.id),
        itemBuilder: (context, item) {
          const imageRadius = 20.0;

          final Group group = Group.fromJson(
              json: item.data() as Map<String, dynamic>, id: item.id);

          return Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    BasicCircleAvatar(
                        radius: imageRadius,
                        child: group.icon(imageRadius * 2)),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      group.name,
                      style: const TextStyle(fontSize: 17),
                    )
                  ],
                ),
                SizedBox(
                  height: 50,
                  child: PaginatedListView(
                    scrollDirection: Axis.horizontal,
                    query: FirebaseFirestore.instance
                        .collection("groups")
                        .doc(group.id)
                        .collection("pages"),
                    itemBuilder: pageTile,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
