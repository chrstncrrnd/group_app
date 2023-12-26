import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/services/auth.dart';
import 'package:group_app/ui/widgets/buttons/next_button.dart';
import 'package:group_app/ui/widgets/dialogs/alert.dart';
import 'package:group_app/ui/widgets/text_input_field.dart';
import 'package:group_app/utils/validators.dart';

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
              TextButton(
                  onPressed: () async {
                    var using = await FirebaseFunctions.instance
                        .httpsCallable("ping")
                        .call();
                    log("a: $using");
                  },
                  child: const Text("Ping")),
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
