import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:groopo/ui/widgets/buttons/next_button.dart';
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
              title: "Welcome to groopo",
              body: "groopo is an app where you can post with friends"),
          PageViewModel(
              decoration: pageDecoration,
              title: "You can create a group with all of your friends",
              body: "Your friends can also join or follow your groups"),
          PageViewModel(
              decoration: pageDecoration,
              title: "Create pages inside your groups to add posts",
              body: "You can create pages for anything!")
        ],
        showNextButton: false,
        overrideDone: NextButton(onPressed: () {
          context.go("/login");
          return null;
        }),
      ),
    );
  }
}
