import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

class BlockWidget extends StatefulWidget {
  const BlockWidget(
      {super.key,
      required this.size,
      required this.startAfter,
      required this.baseQuery,
      required this.itemBuilder,
      required this.lastItemCallback,
      required this.gridDelegate,
      this.before});

  final SliverGridDelegate gridDelegate;

  final List<Widget>? before;
  final int size;
  final DocumentSnapshot? startAfter;
  final Query baseQuery;
  final Function(BuildContext context, DocumentSnapshot item) itemBuilder;
  final Function(DocumentSnapshot lastItem) lastItemCallback;

  @override
  State<BlockWidget> createState() => _BlockWidgetState();
}

class _BlockWidgetState extends State<BlockWidget> {
  late final Query _query;
  VisibilityInfo? _info;

  @override
  void initState() {
    if (widget.startAfter != null) {
      _query = widget.baseQuery
          .limit(widget.size)
          .startAfterDocument(widget.startAfter!);
    } else {
      _query = widget.baseQuery.limit(widget.size);
    }

    super.initState();
  }

  void checkVisibility(VisibilityInfo info) {
    _info = info;
    if (_info == null) {
      return;
    }
    if (_info!.visibleFraction != 0) {
      return;
    }

    Future.delayed(const Duration(seconds: 5)).then((value) => {
          if (_info!.visibleFraction == 0) {log("Unloading block")}
        });
  }

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(
          _query.hashCode.toString() + widget.startAfter.hashCode.toString()),
      onVisibilityChanged: checkVisibility,
      child: StreamBuilder<QuerySnapshot>(
        stream: _query.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("Something went wrong");
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          final data = snapshot.data!;
          widget.lastItemCallback(data.docs.last);

          var beforeLen = widget.before?.length ?? 0;

          return GridView.builder(
            gridDelegate: widget.gridDelegate,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: data.docs.length + beforeLen,
            itemBuilder: (context, index) {
              if (index < beforeLen) {
                return widget.before![index];
              }
              index -= beforeLen;
              final item = data.docs[index];
              return widget.itemBuilder(context, item);
            },
          );
        },
      ),
    );
  }
}
