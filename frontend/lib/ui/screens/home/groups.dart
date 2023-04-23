import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/ui/screens/group/group_list_tile.dart';
import 'package:group_app/ui/widgets/shimmer_loading_indicator.dart';

class GroupsScreens extends StatelessWidget {
  const GroupsScreens({super.key});

  // this needs updating
  Widget tileLoading() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        ShimmerLoadingIndicator(
            child: Text(
          "----------------",
          style: TextStyle(color: Colors.transparent, fontSize: 17),
        )),
        SizedBox(
          height: 10,
        ),
        ShimmerLoadingIndicator(
            child: Padding(
                padding: EdgeInsets.only(top: 5),
                child: Text(
                  "--------------------------------------",
                  style: TextStyle(color: Colors.transparent),
                )))
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My groups",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 27),
        ),
        actions: [
          IconButton(
              onPressed: () => context.push(
                    "/new_group",
                  ),
              icon: const Icon(
                Icons.add_rounded,
                size: 40,
              ))
        ],
      ),
      // No real need for pagination yet as there just isn't much data
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("groups")
            .where("members",
                arrayContains: FirebaseAuth.instance.currentUser?.uid)
            .orderBy("createdAt", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView(
              children: List.generate(4, (index) => tileLoading()),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong..."),
            );
          }

          var docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(
              child: Text("Create or join a group"),
            );
          }
          return ListView.separated(
            separatorBuilder: (context, index) {
              return const Divider(
                height: 1,
                indent: 30,
                endIndent: 30,
                color: Color.fromARGB(47, 255, 255, 255),
              );
            },
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var group = Group.fromJson(json: docs[index].data());
              return GroupListTile(group: group);
            },
          );
        },
      ),
    );
  }
}
