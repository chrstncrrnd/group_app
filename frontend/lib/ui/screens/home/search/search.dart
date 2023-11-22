import "package:cloud_firestore/cloud_firestore.dart";
import "package:flutter/material.dart";
import "package:group_app/models/group.dart";
import "package:group_app/models/user.dart";
import "package:group_app/ui/screens/home/search/search_result_tile.dart";

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> userSearchStream = FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: _textEditingController.text)
        .limit(100)
        .snapshots();

    final Stream<QuerySnapshot> groupSearchStream = FirebaseFirestore.instance
        .collection("groups")
        .where("name", isEqualTo: _textEditingController.text)
        .limit(100)
        .snapshots();

    var streams = [groupSearchStream, userSearchStream];

    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: TextField(
                controller: _textEditingController,
                decoration: const InputDecoration(hintText: "Search"),
                onChanged: (value) => setState(() {}),
              ),
              bottom: const TabBar(
                tabs: [
                  Tab(
                    text: "Groups",
                  ),
                  Tab(
                    text: "Users",
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: List.generate(
                  2,
                  (index) => StreamBuilder(
                        stream: streams[index],
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                              child: Text(
                                "Something went wrong",
                                style: TextStyle(fontSize: 17),
                              ),
                            );
                          }
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator.adaptive(),
                            );
                          }
                          var data = snapshot.data!;
                          return ListView.builder(
                            itemCount: data.docs.length,
                            itemBuilder: (context, i) {
                              var json = data.docChanges[i].doc.data()
                                  as Map<String, dynamic>;
                              var id = data.docChanges[i].doc.id;
                              if (index == 0) {
                                return SearchResult(
                                    resultType: ResultType.group,
                                    group: Group.fromJson(
                                      json: json,
                                      id: id,
                                    ));
                              } else {
                                return SearchResult(
                                    resultType: ResultType.user,
                                    user: User.fromJson(json: json, id: id));
                              }
                            },
                          );
                        },
                      )),
            )));
  }
}
