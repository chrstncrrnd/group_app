import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// todo: add if empty and before
class PullToRefreshPaginatedListView extends StatefulWidget {
  const PullToRefreshPaginatedListView(
      {super.key,
      required this.query,
      this.pageSize = 20,
      required this.itemBuilder,
      this.loaderBuilder,
      this.ifEmpty,
      this.before,
      this.physics});

  final Query query;
  final int pageSize;
  final Function(BuildContext context, DocumentSnapshot item) itemBuilder;
  final Function(BuildContext context)? loaderBuilder;
  final Widget? ifEmpty;
  final List<Widget>? before;
  final ScrollPhysics? physics;

  @override
  State<PullToRefreshPaginatedListView> createState() =>
      _PullToRefreshPaginatedListViewState();
}

class _PullToRefreshPaginatedListViewState
    extends State<PullToRefreshPaginatedListView> {
  int? _itemCount;
  DocumentSnapshot? _lastDoc;
  List<DocumentSnapshot> _items = [];

  Future<void> _loadMore() async {
    Query q = widget.query;
    if (_lastDoc != null) {
      q = q.startAfterDocument(_lastDoc!);
    }
    q = q.limit(widget.pageSize);
    _items.addAll((await q.get()).docs);
    _lastDoc = _items.last;
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _fetchItemCount() async {
    _itemCount = (await widget.query.count().get()).count;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    _loadMore();
    _fetchItemCount();
    super.initState();
  }

  Future<void> onRefresh() async {
    _itemCount = null;
    _lastDoc = null;
    _items = [];
    await _fetchItemCount();
    await _loadMore();
  }

  @override
  Widget build(BuildContext context) {
    if (_itemCount == 0) {
      return widget.ifEmpty ?? const SizedBox();
    }
    return RefreshIndicator.adaptive(
      onRefresh: onRefresh,
      child: ListView.builder(
          physics: widget.physics,
          itemCount: (_itemCount ?? 0) + (widget.before?.length ?? 0),
          itemBuilder: (BuildContext context, int index) {
            if (widget.before != null) {
              if (widget.before!.length > index) {
                return widget.before![index];
              } else {
                index -= widget.before!.length;
              }
            }
            if (_items.length > index) {
              return widget.itemBuilder(context, _items[index]);
            } else {
              _loadMore();
              if (widget.loaderBuilder == null) {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              }
              return widget.loaderBuilder!(context);
            }
          }),
    );
  }
}
