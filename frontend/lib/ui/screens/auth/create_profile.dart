import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/utils/validators.dart';
import 'package:group_app/ui/widgets/next_button.dart';

// Initial profile creation steps
class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  String name = "";
  String username = "";

  int currentIndex = 0;
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 30);

    final pages = [
      Column(
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
            validator: validateName,
          ),
          const SizedBox(
            height: 20,
          ),
          NextButton(onPressed: () => setState(() => currentIndex++))
        ],
      ),
      Column(
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
            validator: validateUsername,
          ),
          const SizedBox(
            height: 20,
          ),
          NextButton(onPressed: () {
            if (formKey.currentState!.validate()) {
              context.pushNamed("create_account", params: {
                "username": username
              }, queryParams: {
                "name": name.isEmpty ? null : name,
              });
            }
          }),
        ],
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Create a new account"),
        leading: currentIndex == 0
            ? IconButton(
                onPressed: () => GoRouter.of(context).pop(),
                icon: const Icon(Icons.close_rounded))
            : IconButton(
                onPressed: () {
                  if (currentIndex > 0) setState(() => currentIndex--);
                },
                icon: const Icon(Icons.arrow_back_ios)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: formKey,
          child: IndexedStack(index: currentIndex, children: pages),
        ),
      ),
    );
  }
}
