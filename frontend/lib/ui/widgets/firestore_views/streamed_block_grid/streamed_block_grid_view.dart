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
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
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
      before: lastDoc == null ? widget.before : null,
      size: widget.blockSize,
      baseQuery: widget.query,
      itemBuilder: widget.itemBuilder,
      gridDelegate: widget.gridDelegate,
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
        physics: widget.physics,
        shrinkWrap: true,
        itemCount: _totalBlocks,
        controller: _scrollController,
        itemBuilder: (context, index) {
          if (index < _blocks.length) {
            return _blocks[index];
          }
          return const Text("Loading...");
        });
  }
}
