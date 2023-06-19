import 'package:flutter/material.dart';

typedef Item = ({
  Widget child,
  Icon icon,
  Function() onPressed,
});

void showContextMenu(
    {required BuildContext context,
    required List<Item> items,
    required RelativeRect position}) async {
  await showMenu(
      context: context,
      position: position,
      items: items
          .map((e) => PopupMenuItem(
                onTap: e.onPressed,
                child: Row(children: [
                  Icon(
                    e.icon.icon,
                    color: Colors.grey,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  e.child
                ]),
              ))
          .toList());
}
