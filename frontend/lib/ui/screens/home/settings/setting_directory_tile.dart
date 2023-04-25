import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingDirectoryTile extends StatelessWidget {
  const SettingDirectoryTile(
      {super.key, required this.name, required this.icon, required this.path});

  final String name;
  final Icon icon;
  final String path;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(path),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white.withOpacity(0.12),
        ),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(
            children: [
              icon,
              const SizedBox(
                width: 10,
              ),
              Text(
                name,
                style: const TextStyle(
                  fontSize: 15.5,
                ),
              ),
            ],
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey,
          )
        ]),
      ),
    );
  }
}
