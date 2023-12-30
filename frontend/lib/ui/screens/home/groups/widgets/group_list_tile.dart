import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:groopo/models/group.dart';
import 'package:groopo/ui/widgets/async/shimmer_loading_indicator.dart';
import 'package:groopo/ui/widgets/basic_circle_avatar.dart';

class GroupListTile extends StatelessWidget {
  const GroupListTile(
      {super.key,
      required this.group,
      this.showArrow = true,
      this.showDescription = true});

  final Group group;
  final bool showArrow;
  final bool showDescription;

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
                              if (group.description != null && showDescription)
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
              if (showArrow)
                const Icon(
                Icons.arrow_forward_ios_rounded,
                size: iconDiameter / 2,
                  color: Colors.grey,
              )
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
              ShimmerLoadingIndicator(
                  child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(shape: BoxShape.circle),
              )),
              const SizedBox(
                width: 10,
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const ShimmerLoadingIndicator(
                  child: Text(
                    "-----------",
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                    margin: const EdgeInsets.only(top: 5),
                    child: const ShimmerLoadingIndicator(
                        child: Text(
                      "--------------------",
                    ))),
              ]),
            ]));
  }
}
