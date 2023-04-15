import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/services/group_creation.dart';
import 'package:group_app/ui/widgets/alert_dialog.dart';
import 'package:group_app/ui/widgets/next_button.dart';
import 'package:group_app/ui/widgets/text_input_field.dart';
import 'package:group_app/utils/validators.dart';

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  String? _groupName;
  String? _groupDescription;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.close_rounded),
        ),
        title: const Text("Create a new group"),
        centerTitle: true,
      ),
      body: Form(
          key: _formKey,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              children: [
                TextInputField(
                  label: "Name",
                  onChanged: (val) => _groupName = val,
                  validator: validateGroupName,
                ),
                TextInputField(
                  label: "Description",
                  onChanged: (val) => _groupDescription = val,
                  minLines: 3,
                  validator: validateGroupDescription,
                ),
                const SizedBox(
                  height: 40,
                ),
                NextButton(onPressed: () async {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                  var res = await createGroup(
                      name: _groupName, description: _groupDescription);
                  if (res != null) {
                    showAdaptiveDialog(context,
                        title: const Text("An error occurred"),
                        content: Text(res),
                        actions: const [Text("Ok")]);
                  }
                  context.pop();
                })
              ],
            ),
          )),
    );
  }
}
