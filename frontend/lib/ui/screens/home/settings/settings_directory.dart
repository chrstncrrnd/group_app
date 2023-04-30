import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/ui/screens/home/settings/setting_directory_tile.dart';

class SettingsDirectoryPage extends StatelessWidget {
  const SettingsDirectoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => context.pop()),
        title: const Text("Settings"),
      ),
      body: Column(
        children: [
          const SettingDirectoryTile(
              icon: Icon(Icons.person),
              name: "Profile",
              path: "/settings/profile_settings"),
          const SettingDirectoryTile(
              icon: Icon(Icons.lock), name: "Privacy", path: "/profile"),
          const SettingDirectoryTile(
              icon: Icon(Icons.help_outline), name: "Help", path: "/profile"),
          const SettingDirectoryTile(
              icon: Icon(Icons.description_outlined),
              name: "Open Source Licenses",
              path: "/profile"),
          const SettingDirectoryTile(
              icon: Icon(Icons.info_outline_rounded),
              name: "About",
              path: "/profile"),
          ElevatedButton(
              onPressed: () async => FirebaseAuth.instance.signOut(),
              child: const Text("Sign out"))
        ],
      ),
    );
  }
}
