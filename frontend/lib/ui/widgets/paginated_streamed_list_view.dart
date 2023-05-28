import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaginatedStreamedListView extends StatefulWidget {
  final Query query;
  final Widget Function(BuildContext context, DocumentSnapshot item)
      itemBuilder;
  final int pageSize;
  final Widget? ifEmpty;

  const PaginatedStreamedListView({
    required this.query,
    required this.itemBuilder,
    this.pageSize = 10,
    this.ifEmpty,
    Key? key,
  }) : super(key: key);

  @override
  State<PaginatedStreamedListView> createState() =>
      _PaginatedStreamedListViewState();
}

class _PaginatedStreamedListViewState extends State<PaginatedStreamedListView> {
  late ScrollController _scrollController;
  final List<DocumentSnapshot> _items = [];
  bool _isLoading = false;
  late Stream<QuerySnapshot> _stream;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _stream = widget.query.snapshots();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _fetchNextPage();
    }
  }

  Future<void> _fetchNextPage() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final lastVisible = _items.isEmpty ? null : _items.last;

    Query nextQuery = widget.query;
    if (lastVisible != null) {
      nextQuery = nextQuery.startAfterDocument(lastVisible);
    }

    nextQuery = nextQuery.limit(widget.pageSize);

    final querySnapshot = await nextQuery.get();
    final newItems = querySnapshot.docs;

    setState(() {
      _isLoading = false;
      _items.addAll(newItems);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          if (_items.isEmpty && widget.ifEmpty != null) {
            return widget.ifEmpty!;
          }
          final items = [..._items, ...snapshot.data!.docs];
          return ListView.builder(
            controller: _scrollController,
            itemCount: items.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < items.length) {
                return widget.itemBuilder(context, items[index]);
              } else {
                return _buildLoader();
              }
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        } else {
          return _buildLoader();
        }
      },
    );
  }

  Widget _buildLoader() {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
