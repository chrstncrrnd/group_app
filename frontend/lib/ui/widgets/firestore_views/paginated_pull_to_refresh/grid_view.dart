import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PullToRefreshPaginatedGridView extends StatefulWidget {
  const PullToRefreshPaginatedGridView(
      {super.key,
      required this.query,
      this.pageSize = 21,
      required this.itemBuilder,
      this.loaderBuilder,
      required this.gridDelegate,
      this.ifEmpty,
      this.before,
      this.physics});

  final Query query;
  // page size should be a multiple of gridDelegate.crossAxisCount
  final int pageSize;
  final SliverGridDelegate gridDelegate;
  final Function(BuildContext context, DocumentSnapshot item) itemBuilder;
  final Function(BuildContext context)? loaderBuilder;
  final ScrollPhysics? physics;

  final Widget? ifEmpty;
  final List<Widget>? before;

  @override
  State<PullToRefreshPaginatedGridView> createState() =>
      _PullToRefreshPaginatedGridViewState();
}

class _PullToRefreshPaginatedGridViewState
    extends State<PullToRefreshPaginatedGridView> {
  int? _itemCount;
  DocumentSnapshot? _lastDoc;
  int? _beforeCount;
  List<DocumentSnapshot> _items = [];

  Future<void> _loadMore() async {
    if (_itemCount == 0) {
      return;
    }
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
    _beforeCount = widget.before?.length ?? 0;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    _fetchItemCount().then((value) => _loadMore());
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
    int? totalCount = ((_itemCount ?? 0) + (_beforeCount ?? 0));

    if (totalCount == 0) {
      return widget.ifEmpty ?? const SizedBox();
    }

    return RefreshIndicator.adaptive(
        onRefresh: onRefresh,
        child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: widget.gridDelegate,
            itemCount: totalCount,
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
            }));
  }
}
