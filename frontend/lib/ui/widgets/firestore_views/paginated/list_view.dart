import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PaginatedListView extends StatefulWidget {
  const PaginatedListView(
      {super.key,
      required this.query,
      required this.pageSize,
      required this.itemBuilder});

  final Query query;
  final int pageSize;
  final Function(BuildContext context, DocumentSnapshot item) itemBuilder;

  @override
  State<PaginatedListView> createState() => _PaginatedListViewState();
}

class _PaginatedListViewState extends State<PaginatedListView> {
  List<DocumentSnapshot> items = List.empty(growable: true);

  int? _total;

  @override
  void initState() {
    widget.query.count().get().then((value) => setState(
          () {
            _total = value.count;
          },
        ));
    super.initState();
  }

  Future<void> _loadMore() async {
    Query q = widget.query.limit(widget.pageSize);
    if (items.isNotEmpty) {
      q = q.startAfterDocument(items.last);
    }

    items.addAll((await q.get()).docs);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _total,
      itemBuilder: (context, index) {
        if (index >= items.length) {
          _loadMore().then((value) => setState(
                () {},
              ));
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }
        return widget.itemBuilder(context, items[index]);
      },
    );
  }
}
