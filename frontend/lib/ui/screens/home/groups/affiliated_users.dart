import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/user.dart';
import 'package:group_app/ui/widgets/alert.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/progress_indicator_button.dart';
import 'package:group_app/ui/widgets/shimmer_loading_indicator.dart';
import 'package:group_app/ui/widgets/suspense.dart';

class AffiliatedUsersScreenExtra {
  AffiliatedUsersScreenExtra(
      {required this.users,
      required this.title,
      required this.isAdmin,
      required this.onRemove});
  final String title;
  final List<String> users;
  final bool isAdmin;
  final Future<String?> Function(String userId) onRemove;
}

class AffiliatedUsersScreen extends StatefulWidget {
  const AffiliatedUsersScreen({super.key, required this.extra});

  final AffiliatedUsersScreenExtra extra;

  @override
  State<AffiliatedUsersScreen> createState() => _AffiliatedUsersScreenState();
}

class _AffiliatedUsersScreenState extends State<AffiliatedUsersScreen> {
  Future<String?> onRemove(String userId) async {
    var res = await widget.extra.onRemove(userId);
    if (res != null) {
      return res;
    }
    setState(() => widget.extra.users.remove(userId));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.extra.title),
      ),
      body: ListView.builder(
          itemCount: widget.extra.users.length,
          itemBuilder: (context, index) => AffiliatedUser(
                userId: widget.extra.users[index],
                isAdmin: widget.extra.isAdmin,
                onRemove: onRemove,
              )),
    );
  }
}

class AffiliatedUser extends StatelessWidget {
  const AffiliatedUser(
      {super.key,
      required this.userId,
      required this.isAdmin,
      required this.onRemove});

  final String userId;
  final bool isAdmin;
  // not optional because it will fail if run and besides the button
  // is not shown
  final Future<String?> Function(String userId) onRemove;

  @override
  Widget build(BuildContext context) {
    const pfpSize = 23.0;
    const mainStyle = TextStyle(fontSize: 16, color: Colors.white);

    return Suspense<User>(
        future: User.fromId(id: userId),
        placeholder: ListTile(
          leading: ShimmerLoadingIndicator(
            borderRadius: BorderRadius.circular(pfpSize),
            child: const BasicCircleAvatar(
              radius: pfpSize,
              child: SizedBox(
                height: pfpSize,
                width: pfpSize,
              ),
            ),
          ),
          title: const ShimmerLoadingIndicator(
            child: Text("-----------"),
          ),
          titleTextStyle: mainStyle,
        ),
        builder: (context, user) {
          if (user == null) {
            return const Text("Something went wrong");
          }
          final userNamed = user.name != null;

          return ListTile(
            leading: BasicCircleAvatar(
                radius: pfpSize, child: user.pfp(pfpSize * 2)),
            title: Text(user.name ?? user.username),
            titleTextStyle: mainStyle,
            subtitle: userNamed ? Text(user.username) : null,
            onTap: () => context.push("/user", extra: user),
            trailing: isAdmin
                ? ProgressIndicatorButton(
                    progressIndicatorHeight: pfpSize,
                    progressIndicatorWidth: pfpSize,
                    child: const Text("Remove"),
                    onPressed: () => isAdmin
                        ? onRemove(user.id).then((value) {
                            if (value != null) {
                              showAlert(context,
                                  title: "Something went wrong",
                                  content: value);
                            }
                          })
                        : null,
                  )
                : null,
          );
        });
  }
}