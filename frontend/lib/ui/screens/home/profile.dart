import 'package:flutter/material.dart';
import 'package:group_app/models/current_user.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/fallback_text.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var currentUser = Provider.of<CurrentUser?>(context, listen: true);
    print("building profile screen");

    return Scaffold(
        appBar: AppBar(
          title: FbText("@${currentUser?.username}"),
          actions: [
            IconButton(
                onPressed: () => print("open settings"),
                icon: const Icon(Icons.menu_rounded))
          ],
        ),
        body: Center(
            child: Column(
          children: [
            if (currentUser?.name != null)
              Text(
                currentUser!.name!,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
              ),
            BasicCircleAvatar(
              radius: 50,
              child: currentUser!.pfp(60),
            )
          ],
        )));
  }
}
