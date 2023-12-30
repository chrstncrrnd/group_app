import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:groopo/services/auth.dart';
import 'package:groopo/ui/widgets/buttons/next_button.dart';
import 'package:groopo/ui/widgets/dialogs/alert.dart';
import 'package:groopo/ui/widgets/text_input_field.dart';
import 'package:groopo/utils/validators.dart';

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
            "Welcome to groopo, what's your name?",
            style: TextStyle(fontSize: 30),
          ),
          const SizedBox(
            height: 20,
          ),
          TextInputField(
            label: "Name",
            onChanged: (value) {
              name = value.trim();
            },
            maxLines: 1,
            validator: validateName,
          ),
          const SizedBox(
            height: 20,
          ),
          NextButton(onPressed: () {
            setState(() => currentIndex++);
            return null;
          })
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
          TextInputField(
            label: "Username",
            onChanged: (value) {
              username = value.trim();
            },
            maxLines: 1,
            validator: validateUsername,
          ),
          const SizedBox(
            height: 20,
          ),
          NextButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) {
                return "Please double check the fields";
              }
              var res = await usernameAvailable(username);
              return res;
            },
            after: (res) {
              if (res != null) {
                showAlert(context, title: "An error occurred", content: res);
              } else {
                context.pushNamed("create_account", pathParameters: {
                  "username": username
                }, queryParameters: {
                  "name": name.isEmpty ? null : name,
                });
              }
            },
          ),
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
