import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StreamedGridView extends StatefulWidget {
  final Query query;
  final Widget Function(BuildContext context, DocumentSnapshot item)
      itemBuilder;
  final Widget? ifEmpty;
  final SliverGridDelegate gridDelegate;
  final List<Widget>? before;
  final ScrollPhysics? physics;
  final int pageSize;

  const StreamedGridView({
    required this.gridDelegate,
    required this.query,
    required this.itemBuilder,
    this.physics,
    this.before,
    this.ifEmpty,
    this.pageSize = 20,
    Key? key,
  }) : super(key: key);

  @override
  State<StreamedGridView> createState() => _StreamedGridViewState();
}

class _StreamedGridViewState extends State<StreamedGridView> {
  late Query _query;
  int _currentlyLoaded = 0;
  int? _total;

  late final ScrollController _scrollController;

  @override
  void initState() {
    _query = widget.query.limit(widget.pageSize);
    _query.count().get().then((value) => _total = value.count);

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    super.initState();
  }

  void _addMore() {
    setState(() {
      _query = _query.limit(_currentlyLoaded + widget.pageSize);
      _currentlyLoaded += widget.pageSize;
    });
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        _currentlyLoaded < _total!) {
      _addMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            _total == null) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        } else if (snapshot.hasError || snapshot.data == null) {
          return const Center(
            child: Text("Something went wrong..."),
          );
        }
        if (_total == 0) {
          return widget.ifEmpty ?? Container();
        }

        var items = snapshot.data!.docs;

        return GridView.builder(
          controller: _scrollController,
          physics: widget.physics,
          shrinkWrap: true,
          gridDelegate: widget.gridDelegate,
          itemCount: items.length +
              (widget.before != null ? widget.before!.length : 0),
          itemBuilder: (context, index) {
            if (widget.before != null && index < widget.before!.length) {
              return widget.before![index];
            }
            index = index - (widget.before?.length ?? 0);
            return widget.itemBuilder(context, items[index]);
          },
        );
      },
    );
  }
}
