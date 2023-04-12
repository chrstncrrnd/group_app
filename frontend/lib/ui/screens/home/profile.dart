import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/fallback_text.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CurrentUser>(
        stream: CurrentUser.asStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text("An error occurred"),
            );
          }
          var currentUser = snapshot.data!;
          return Scaffold(
              appBar: AppBar(
                title: FbText("@${currentUser.username}"),
                actions: [
                  IconButton(
                      onPressed: () => print("open settings"),
                      icon: const Icon(Icons.menu_rounded))
                ],
              ),
              body: Center(
                  child: Column(
                children: [
                  if (currentUser.name != null)
                    Text(
                      currentUser.name!,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 28),
                    ),
                  BasicCircleAvatar(
                    radius: 50,
                    child: currentUser.pfp(60),
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
