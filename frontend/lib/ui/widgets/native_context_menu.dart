import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

typedef Item = ({Widget child, Function() onPressed});

void showNativeContextMenu(BuildContext context, List<Item> items,
    {RelativeRect? position}) async {
  if (Theme.of(context).platform == TargetPlatform.iOS) {
    await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoContextMenu(
          actions: buildContextMenuItems(context, items),
          child: const Text('Long press me'),
        );
      },
    );
  } else {
    await showMenu(
      context: context,
      // we are assuming that its always going to be at the top right of the screen
      position: position ??
          RelativeRect.fromDirectional(
              top: 0,
              end: 0,
              textDirection: TextDirection.ltr,
              start: 1,
              bottom: 1),
      items: buildContextMenuItems(context, items),
    );
  }
}

List<PopupMenuEntry<dynamic>> buildContextMenuItems(
    BuildContext context, List<Item> items) {
  return items.map((widget) {
    return PopupMenuItem(
      child: widget.child,
      onTap: () {
        handleContextMenuSelection(context, widget);
      },
    );
  }).toList();
}

void handleContextMenuSelection(BuildContext context, Item selectedItem) {
  // Handle the selected widget
  selectedItem.onPressed.call();
}
