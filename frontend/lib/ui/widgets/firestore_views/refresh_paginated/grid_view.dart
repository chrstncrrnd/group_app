import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RefreshPaginatedGridView extends StatefulWidget {
  const RefreshPaginatedGridView(
      {super.key,
      required this.gridDelegate,
      required this.itemBuilder,
      required this.query,
      this.pageSize = 2});

  // todo: add if empty and before and stuff like that
  // todo: add the load stuff

  final SliverGridDelegate gridDelegate;
  final Widget Function(BuildContext context, DocumentSnapshot item)
      itemBuilder;

  final Query query;
  final int pageSize;

  @override
  State<RefreshPaginatedGridView> createState() =>
      _RefreshPaginatedGridViewState();
}

class _RefreshPaginatedGridViewState extends State<RefreshPaginatedGridView> {
  int? _total;
  final List<DocumentSnapshot> _items = [];

  late Query _query;

  DocumentSnapshot? _lastDoc;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    _query = widget.query;
    _lastDoc = null;
    _scrollController.addListener(_scrollListener);
    _load().then((value) => setState(() {}));
    super.initState();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent) {
      log("loading more");
      _load();
    }
  }

  Future<void> _load() async {
    if (_items.length >= (_total ?? double.infinity)) {
      return;
    }

    if (_lastDoc != null) {
      _query = _query.startAfterDocument(_lastDoc!);
    }

    // First time running
    if (_lastDoc == null) {
      _total = (await _query.count().get()).count;
    }

    QuerySnapshot querySnapshot = await _query.limit(widget.pageSize).get();

    _lastDoc = querySnapshot.docs.last;

    _items.addAll(querySnapshot.docs);
    setState(() {});
  }

  Future<void> _refresh() async {
    _items.clear();
    _query = widget.query;
    _lastDoc = null;
    await _load();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: _refresh,
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: widget.gridDelegate,
        itemCount: _items.length,
        itemBuilder: (context, index) {
          log("item id: ${_items[index].id} index: $index");
          return widget.itemBuilder(context, _items[index]);
        },
      ),
    );
  }
}
