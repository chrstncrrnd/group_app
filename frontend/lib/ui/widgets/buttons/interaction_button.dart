import 'dart:async';

import 'package:flutter/material.dart';

enum InteractionButtonState { active, inactive, _loading, error }

class InteractionButton extends StatefulWidget {
  const InteractionButton(
      {super.key,
      this.before,
      this.after,
      this.onTap,
      this.initState,
      required this.activeTitle,
      required this.inactiveTitle,
      this.errorTitle = "Error",
      this.loadingText = "Loading"});

  final Widget? before;
  final Widget? after;

  final String activeTitle;
  final String inactiveTitle;
  final String errorTitle;
  final String loadingText;

  final Future<InteractionButtonState> Function()? initState;
  final Future<InteractionButtonState> Function(InteractionButtonState)? onTap;

  @override
  State<InteractionButton> createState() => _InteractionButtonState();
}

class _InteractionButtonState extends State<InteractionButton> {
  late InteractionButtonState state;

  @override
  void initState() {
    super.initState();

    if (widget.initState != null) {
      state = InteractionButtonState._loading;
      widget.initState!.call().then((value) => setState(() => state = value));
    } else {
      // default
      state = InteractionButtonState.active;
    }
  }

  Future<void> onTap() async {
    if (widget.onTap == null) {
      return;
    }
    if (state == InteractionButtonState._loading) {
      return;
    }

    var prevState = state;
    setState(() {
      state = InteractionButtonState._loading;
    });
    var res = await widget.onTap!(prevState);
    setState(() {
      state = res;
    });
  }

  Color getBgColor() {
    switch (state) {
      case InteractionButtonState._loading:
        return const Color.fromARGB(255, 56, 56, 56);
      case InteractionButtonState.active:
        return Colors.white;
      case InteractionButtonState.inactive:
        return const Color.fromARGB(255, 31, 31, 31);
      case InteractionButtonState.error:
        return Colors.red.shade900;
    }
  }

  Color getTextColor() {
    switch (state) {
      case InteractionButtonState._loading:
        return Colors.white;
      case InteractionButtonState.active:
        return Colors.black;
      case InteractionButtonState.inactive:
        return Colors.white;
      case InteractionButtonState.error:
        return Colors.white;
    }
  }

  Widget getTitle() {
    final TextStyle style = TextStyle(
        fontWeight: FontWeight.bold, fontSize: 17, color: getTextColor());

    switch (state) {
      case InteractionButtonState._loading:
        return Text(
          widget.loadingText,
          style: style,
        );
      case InteractionButtonState.active:
        return Text(
          widget.activeTitle,
          style: style,
        );
      case InteractionButtonState.inactive:
        return Text(
          widget.inactiveTitle,
          style: style,
        );
      case InteractionButtonState.error:
        return Text(
          widget.errorTitle,
          style: style,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
              color: getBgColor(), borderRadius: BorderRadius.circular(17)),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (widget.before != null) widget.before!,
                getTitle(),
                if (widget.after != null) widget.after!
              ],
            ),
          )),
    );
  }
}
