import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:group_app/ui/screens/home/settings/setting_directory_tile.dart';
import 'package:group_app/utils/clear_cache.dart';

class SettingsDirectoryPage extends StatelessWidget {
  const SettingsDirectoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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

          const SettingDirectoryTile(
            icon: Icon(Icons.delete_forever_rounded),
            name: "Clear cache",
            onPressed: clearCache,
          ),
          ElevatedButton(
              onPressed: () async => FirebaseAuth.instance.signOut(),
              child: const Text("Sign out"))
        ],
      ),
    );
  }
}
