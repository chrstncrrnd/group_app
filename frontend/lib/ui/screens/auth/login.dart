import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:groopo/services/auth.dart';
import 'package:groopo/ui/widgets/buttons/next_button.dart';
import 'package:groopo/ui/widgets/dialogs/alert.dart';
import 'package:groopo/ui/widgets/text_input_field.dart';
import 'package:groopo/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
              child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Log in",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
              TextInputField(
                label: 'Email',
                maxLines: 1,
                validator: validateEmail,
                onChanged: (value) {
                  _email = value.trim();
                },
              ),
              TextInputField(
                maxLines: 1,
                label: 'Password',
                obscureText: true,
                onChanged: (value) {
                  _password = value;
                },
                validator: validatePassword,
              ),
              const SizedBox(
                height: 5,
              ),
              TextButton(
                  onPressed: () {
                    context.push(
                      "/create_profile",
                    );
                  },
                  child: const Text("Don't have an account?")),
              const SizedBox(height: 10),
              NextButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return "Please double check all of the inputs";
                  }
                  String? error = await logUserIn(_email, _password);
                  return error;
                },
                after: (error) {
                  if (error != null) {
                    showAlert(context,
                        title: "An error occurred", content: error);
                  }
                },
              ),
            ],
          ),
        ),
      ))),
    );
  }
}
