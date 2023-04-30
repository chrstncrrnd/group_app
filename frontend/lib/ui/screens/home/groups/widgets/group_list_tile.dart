import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:group_app/models/group.dart';
import 'package:group_app/ui/widgets/basic_circle_avatar.dart';
import 'package:group_app/ui/widgets/shimmer_loading_indicator.dart';

class GroupListTile extends StatelessWidget {
  const GroupListTile({super.key, required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push("/group", extra: group),
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                BasicCircleAvatar(radius: 20, child: group.icon(40)),
                const SizedBox(
                  width: 10,
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    group.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (group.description != null)
                    Container(
                        margin: const EdgeInsets.only(top: 5),
                        child: Text(
                          group.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ))
                ]),
              ])),
    );
  }
}

class GroupListTileLoading extends StatelessWidget {
  const GroupListTileLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              BasicCircleAvatar(
                radius: 20,
                child: ShimmerLoadingIndicator(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const ShimmerLoadingIndicator(
                  child: Text(
                    "-----------",
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.transparent),
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(top: 5),
                    child: const ShimmerLoadingIndicator(
                        child: Text(
                      "--------------------",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.transparent),
                    ))),
              ]),
            ]));
  }
}
