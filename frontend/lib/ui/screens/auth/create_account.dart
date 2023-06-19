import 'package:flutter/material.dart';
import 'package:group_app/services/auth.dart';
import 'package:group_app/ui/widgets/buttons/next_button.dart';
import 'package:group_app/ui/widgets/dialogs/alert.dart';
import 'package:group_app/utils/validators.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen(
      {super.key, required this.name, required this.username});

  final String? name;
  final String username;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = "";
  String _password = "";

  Widget formField(String? Function(String?) validator, String label,
      Function(String?) onChanged) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
      ),
      validator: validator,
      onChanged: onChanged,
      obscureText: label == "Password",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Form(
            key: _formKey,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 30.0, vertical: 30),
              child: Column(
                children: [
                  const Text(
                    "Create your account",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  formField(validateEmail, "Email", (value) {
                    if (value != null) _email = value.trim();
                  }),
                  const SizedBox(
                    height: 10,
                  ),
                  formField(validatePassword, "Password", (value) {
                    if (value != null) _password = value;
                  }),
                  const SizedBox(
                    height: 20,
                  ),
                  NextButton(
                    onPressed: () async {
                      if (!_formKey.currentState!.validate()) {
                        return "Please double check the fields";
                      }

                      String? error = await createUser(
                          _email, _password, widget.username, widget.name);
                      return error;
                    },
                    after: (error) {
                      if (error != null) {
                        showAlert(context,
                            title: "An error occurred", content: error);
                      }
                    },
                  )
                ],
              ),
            )));
  }
}
