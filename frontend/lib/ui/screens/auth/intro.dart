import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/ui/widgets/next_button.dart';
import 'package:introduction_screen/introduction_screen.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const PageDecoration pageDecoration =
        PageDecoration(bodyAlignment: Alignment.center);
    return Scaffold(
      body: IntroductionScreen(
        pages: [
          PageViewModel(
              decoration: pageDecoration,
              title: "Welcome to group_app",
              body: "group_app is an app where you can post with friends"),
          PageViewModel(
              decoration: pageDecoration,
              title: "You can create or join a group with all of your friends",
              body: "Your friends can also follow your groups"),
          PageViewModel(
              decoration: pageDecoration,
              title: "Everyone in your group can add pictures",
              body: "You can then comment or reply with a photo")
        ],
        showNextButton: false,
        overrideDone: NextButton(onPressed: () {
          context.go("/login");
        }),
      ),
    );
  }
}
