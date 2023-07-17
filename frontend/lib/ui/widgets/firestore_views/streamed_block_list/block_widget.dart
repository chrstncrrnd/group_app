import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BlockWidget extends StatefulWidget {
  const BlockWidget(
      {super.key,
      required this.size,
      required this.startAfter,
      required this.baseQuery,
      required this.itemBuilder,
      required this.lastItemCallback});

  final int size;
  final DocumentSnapshot? startAfter;
  final Query baseQuery;
  final Function(BuildContext context, DocumentSnapshot item) itemBuilder;
  final Function(DocumentSnapshot lastItem) lastItemCallback;

  @override
  State<BlockWidget> createState() => _BlockWidgetState();
}

class _BlockWidgetState extends State<BlockWidget> {
  late final Query _query;

  @override
  void initState() {
    if (widget.startAfter != null) {
      _query = widget.baseQuery
          .limit(widget.size)
          .startAfterDocument(widget.startAfter!);
    } else {
      _query = widget.baseQuery.limit(widget.size);
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _query.snapshots(),
      builder: (context, snapshot) {
        
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator.adaptive(),
          );
        }

        final data = snapshot.data!;
        widget.lastItemCallback(data.docs.last);

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: data.docs.length,
          itemBuilder: (context, index) {
            final item = data.docs[index];
            return widget.itemBuilder(context, item);
          },
        );
      },
    );
  }
}
