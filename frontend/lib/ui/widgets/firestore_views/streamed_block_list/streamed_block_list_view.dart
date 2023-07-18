import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:group_app/ui/widgets/firestore_views/streamed_block_list/block_widget.dart';

class StreamedBlockListView extends StatefulWidget {
  const StreamedBlockListView(
      {super.key,
      required this.query,
      this.physics,
      this.blockSize = 20,
      this.before,
      required this.itemBuilder,
      this.ifEmpty});

  final Widget? ifEmpty;
  final Query query;
  final int blockSize;
  final List<Widget>? before;
  final ScrollPhysics? physics;
  final Function(BuildContext context, DocumentSnapshot item) itemBuilder;

  @override
  State<StreamedBlockListView> createState() => _StreamedBlockListViewState();
}

class _StreamedBlockListViewState extends State<StreamedBlockListView> {
  final List<BlockWidget> _blocks = [];
  DocumentSnapshot? lastDoc;
  int _totalBlocks = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    log("init state");
    widget.query.count().get().then((value) {
      _totalBlocks = (value.count / widget.blockSize).ceil();
      if (_totalBlocks > 0) {
        _loadNewBlock();
      }
    });
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _blocks.length < _totalBlocks) {
      _loadNewBlock();
      setState(() {});
    }
  }

  void _updateLastDoc(DocumentSnapshot doc) {
    lastDoc = doc;
  }

  void _loadNewBlock() {
    _blocks.add(BlockWidget(
      size: widget.blockSize,
      baseQuery: widget.query,
      itemBuilder: widget.itemBuilder,
      startAfter: lastDoc,
      lastItemCallback: _updateLastDoc,
    ));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_totalBlocks == 0) {
      return widget.ifEmpty ?? Container();
    }
    return ListView.builder(
        shrinkWrap: true,
        physics: widget.physics,
        itemCount: _totalBlocks + (widget.before?.length ?? 0),
        controller: _scrollController,
        itemBuilder: (context, index) {

          if (widget.before != null && index < widget.before!.length) {
            return widget.before![index];
          }
          index += widget.before?.length ?? 0;

          if (index < _blocks.length) {
            return _blocks[index];
          }
          return const Text("Cum");
        });
  }
}
