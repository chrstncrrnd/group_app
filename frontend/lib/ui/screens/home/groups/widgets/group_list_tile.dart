import 'package:auto_size_text/auto_size_text.dart';
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
    const iconDiameter = 40.0;
    
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push("/group", extra: group),
      child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      BasicCircleAvatar(
                          radius: iconDiameter / 2,
                          child: group.icon(iconDiameter)),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                group.name,
                                maxLines: 1,
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
                                      style: TextStyle(
                                          color: Colors.grey.shade300),
                                    ))
                            ]),
                      ),
                    ]),
              ),
              IconButton(
                  onPressed: () => print("new post on group ${group.name}"),
                  icon: const Icon(
                    Icons.add,
                    size: iconDiameter,
                    color: Colors.grey,
                  ))
            ],
          )),
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
