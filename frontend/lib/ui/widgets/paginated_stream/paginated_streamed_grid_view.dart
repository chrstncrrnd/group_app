import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaginatedStreamedGridView extends StatefulWidget {
  final Query query;
  final Widget Function(BuildContext context, DocumentSnapshot item)
      itemBuilder;
  final int pageSize;
  final Widget? ifEmpty;
  final SliverGridDelegate gridDelegate;
  final List<Widget>? before;
  final ScrollPhysics? physics;

  const PaginatedStreamedGridView({
    required this.gridDelegate,
    required this.query,
    required this.itemBuilder,
    this.physics,
    this.before,
    this.pageSize = 10,
    this.ifEmpty,
    Key? key,
  }) : super(key: key);

  @override
  State<PaginatedStreamedGridView> createState() =>
      _PaginatedStreamedGridViewState();
}

class _PaginatedStreamedGridViewState extends State<PaginatedStreamedGridView> {
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
          final items = [..._items, ...snapshot.data!.docs];
          var itemCount = items.length + (_isLoading ? 1 : 0);
          return itemCount == 0 && widget.ifEmpty != null
              ? widget.ifEmpty!
              : GridView.builder(
                  physics: widget.physics,
                  shrinkWrap: true,
                  gridDelegate: widget.gridDelegate,
                  controller: _scrollController,
                  itemCount: itemCount + (widget.before?.length ?? 0),
                  itemBuilder: (context, index) {
                    if (widget.before != null &&
                        index < widget.before!.length) {
                      return widget.before![index];
                    }
                    index = index - (widget.before?.length ?? 0);
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
        child: CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
