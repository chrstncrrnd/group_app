import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String name = "";
  String username = "";

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 30);
    var pages = [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Text(
              "Welcome to group_app, what's your name?",
              style: TextStyle(fontSize: 30),
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: const InputDecoration(
                label: Text("Name"),
              ),
              onChanged: (value) {
                name = value.trim();
              },
            )
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            name.isEmpty
                ? const Text(
                    "Choose a username",
                    style: textStyle,
                  )
                : Wrap(
                    children: [
                      const Text(
                        "Hi ",
                        style: textStyle,
                      ),
                      Text(
                        "$name, ",
                        style: textStyle.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Text(
                        "choose a username",
                        style: textStyle,
                      )
                    ],
                  ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: const InputDecoration(
                label: Text("Username"),
              ),
              onChanged: (value) {
                username = value.trim();
              },
            )
          ],
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Create a new account")),
      body: SafeArea(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Form(
          child: IndexedStack(index: currentIndex, children: pages),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
                onPressed: () {
                  if (currentIndex > 0) setState(() => currentIndex--);
                },
                icon: const Icon(Icons.arrow_back_ios),
                label: const Text("Back")),
            ElevatedButton.icon(
                onPressed: () {
                  if (currentIndex < pages.length - 1) {
                    setState(() => currentIndex++);
                  }
                },
                icon: const Icon(Icons.arrow_forward_ios),
                label: const Text("Next")),
          ],
        )
      ])),
    );
  }
}
