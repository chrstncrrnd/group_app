import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// todo: add if empty and before
class PaginatedListView extends StatefulWidget {
  const PaginatedListView(
      {super.key,
      required this.query,
      this.pageSize = 20,
      required this.itemBuilder,
      this.loaderBuilder,
      this.scrollDirection,
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
  final Axis? scrollDirection;

  @override
  State<PaginatedListView> createState() => _PaginatedListViewState();
}

class _PaginatedListViewState extends State<PaginatedListView> {
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
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    _fetchItemCount().then((_) => _loadMore());
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
    return ListView.builder(
        scrollDirection: widget.scrollDirection ?? Axis.vertical,
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
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            return widget.loaderBuilder!(context);
          }
        });
  }
}
