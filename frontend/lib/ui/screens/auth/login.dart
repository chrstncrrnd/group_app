import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/services/auth.dart';
import 'package:group_app/utils/validators.dart';
import 'package:group_app/widgets/next_button.dart';

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
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
                validator: validateEmail,
                onSaved: (value) {
                  if (value != null) _email = value.trim();
                },
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
                validator: validatePassword,
                obscureText: true,
                onSaved: (value) {
                  if (value != null) _password = value;
                },
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
                onPressed: () async => await logUserIn(_email, _password),
              ),
            ],
          ),
        ),
      ))),
    );
  }
}
