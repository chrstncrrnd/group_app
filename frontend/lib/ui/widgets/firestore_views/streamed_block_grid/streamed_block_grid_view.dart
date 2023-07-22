import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_app/ui/widgets/firestore_views/streamed_block_grid/block_widget.dart';

class StreamedBlockGridView extends StatefulWidget {
  const StreamedBlockGridView(
      {super.key,
      required this.query,
      this.blockSize = 21,
      required this.itemBuilder,
      this.ifEmpty,
      this.physics,
      this.before,
      this.gridDelegate = const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
      )});

  final SliverGridDelegate gridDelegate;
  final List<Widget>? before;
  final Widget? ifEmpty;
  final Query query;
  final ScrollPhysics? physics;
  // block size should be a multiple of gridDelegate.crossAxisCount
  final int blockSize;
  final Function(BuildContext context, DocumentSnapshot item) itemBuilder;

  @override
  State<StreamedBlockGridView> createState() => _StreamedBlockGridViewState();
}

class _StreamedBlockGridViewState extends State<StreamedBlockGridView> {
  final List<BlockWidget> _blocks = [];
  DocumentSnapshot? lastDoc;
  int _totalBlocks = 0;

  @override
  void initState() {
    widget.query.count().get().then((value) {
      _totalBlocks = (value.count / widget.blockSize).ceil();
      setState(() {});
    });
    super.initState();
  }

  void _updateLastDoc(DocumentSnapshot doc) {
    lastDoc = doc;
    log("updated last doc fr to $doc");
  }

  void _loadNewBlock() async {
    log("the last doc now is $lastDoc");
    final block = BlockWidget(
      before: lastDoc == null ? widget.before : null,
      size: widget.blockSize,
      baseQuery: widget.query,
      itemBuilder: widget.itemBuilder,
      gridDelegate: widget.gridDelegate,
      startAfter: lastDoc,
      lastItemCallback: _updateLastDoc,
    );
    _blocks.add(block);
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_totalBlocks == 0) {
      return widget.ifEmpty ?? Container();
    }
    return ListView.separated(
        physics: widget.physics,
        shrinkWrap: true,
        itemCount: _totalBlocks,
        separatorBuilder: (context, _) =>
            widget.gridDelegate is SliverGridDelegateWithFixedCrossAxisCount
                ? SizedBox(
                    height: (widget.gridDelegate
                            as SliverGridDelegateWithFixedCrossAxisCount)
                        .mainAxisSpacing)
                : Container(),
        itemBuilder: (context, index) {
          if (index < _blocks.length) {
            return _blocks[index];
          }
          _loadNewBlock();
          return const Text("Loading...");
        });
  }
}
