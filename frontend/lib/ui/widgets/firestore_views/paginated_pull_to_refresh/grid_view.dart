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
  int? _numGrids;
  int? _itemCount;
  DocumentSnapshot? _lastDoc;
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
    _numGrids = (_itemCount! / widget.pageSize).ceil();
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
    if (_itemCount == 0) {
      return widget.ifEmpty ?? const SizedBox();
    }
    return RefreshIndicator.adaptive(
      onRefresh: onRefresh,
      child: ListView.separated(
          physics: widget.physics,
          shrinkWrap: true,
          itemCount: _numGrids ?? 0,
          separatorBuilder: (context, _) =>
              widget.gridDelegate is SliverGridDelegateWithFixedCrossAxisCount
                  ? SizedBox(
                      height: (widget.gridDelegate
                              as SliverGridDelegateWithFixedCrossAxisCount)
                          .mainAxisSpacing)
                  : Container(),
          itemBuilder: (BuildContext context, int index) {
            int gridItemCount = widget.pageSize;
            if (_numGrids == index + 1) {
              gridItemCount = _itemCount! - (widget.pageSize * index);
            }
            bool hasBefore = widget.before != null && index == 0;
            if (hasBefore) {
              gridItemCount += widget.before!.length;
            }

            return GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: widget.gridDelegate,
                itemCount: gridItemCount,
                itemBuilder: (BuildContext context, int index) {
                  if (hasBefore) {
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
                });
          }),
    );
  }
}
