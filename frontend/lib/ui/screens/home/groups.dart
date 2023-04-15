import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';

class GroupsScreens extends StatelessWidget {
  const GroupsScreens({super.key});

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
      // THIS IS JUST TEMP!!!!!!
      // actual should use pagination
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("groups")
            .where("members",
                arrayContains: FirebaseAuth.instance.currentUser?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text("Something went wrong..."),
            );
          }
          var docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var group = Group.fromJson(json: docs[index].data());
              return Text("Group name: ${group.name}");
            },
          );
        },
      ),
    );
  }
}
