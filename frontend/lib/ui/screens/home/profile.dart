import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/shimmer_loading_indicator.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  final _nameTextStyle =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 28);

  // more or less mimics what the actual ui looks like
  Widget buildPlaceholder(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const ShimmerLoadingIndicator(
        child: Text(
          "-------------------",
          style: TextStyle(color: Colors.transparent),
        ),
      )),
      body: Center(
          child: Column(
        children: [
          ShimmerLoadingIndicator(
            width: 120,
            height: 120,
            borderRadius: BorderRadius.circular(100),
          ),
          const SizedBox(
            height: 20,
          ),
          ShimmerLoadingIndicator(
            child: Text(
              "-------------------",
              style: _nameTextStyle.copyWith(color: Colors.transparent),
            ),
          )
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CurrentUser>(
        stream: CurrentUser.asStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return buildPlaceholder(context);
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text("An error occurred"),
            );
          }
          var currentUser = snapshot.data!;
          return Scaffold(
              appBar: AppBar(
                title: Text("@${currentUser.username}"),
                actions: [
                  IconButton(
                      onPressed: () => print("open settings"),
                      icon: const Icon(Icons.menu_rounded))
                ],
              ),
              body: Center(
                  child: Column(
                children: [
                  BasicCircleAvatar(
                    radius: 50,
                    child: currentUser.pfp(100),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (currentUser.name != null)
                    Text(
                      currentUser.name!,
                      style: _nameTextStyle,
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                      onPressed: FirebaseAuth.instance.signOut,
                      child: const Text("Sign out"))
                ],
              )));
        });
  }
}