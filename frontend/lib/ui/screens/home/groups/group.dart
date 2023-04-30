import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';

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
        return SafeArea(
            child: Column(
          children: [
            Container(
              height: 300,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (group.bannerDlUrl != null)
                    Image.network(
                      group.bannerDlUrl!,
                      fit: BoxFit.cover,
                    ),
                  Positioned(
                      top: 10,
                      left: 10,
                      child: IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll(
                                Colors.white.withOpacity(0.15))),
                      )),
                  Positioned(
                      bottom: 10,
                      left: 10,
                      child: Row(
                        children: [
                          BasicCircleAvatar(radius: 30, child: group.icon(60)),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            group.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 30),
                          ),
                        ],
                      ))
                ],
              ),
            ),
          ],
        ));
      },
    );
  }
}
