import 'package:cloud_functions/cloud_functions.dart';

Future<void> followGroup(String groupId) async {
  await FirebaseFunctions.instance
      .httpsCallable("followGroup")
      .call({"groupId": groupId});
}

Future<void> unFollowGroup(String groupId) async {
  await FirebaseFunctions.instance
      .httpsCallable("unFollowGroup")
      .call({"groupId": groupId});
}

Future<void> joinGroup(String groupId) async {
  await FirebaseFunctions.instance
      .httpsCallable("joinGroup")
      .call({"groupId": groupId});
}

Future<void> leaveGroup(String groupId) async {
  await FirebaseFunctions.instance
      .httpsCallable("leaveGroup")
      .call({"groupId": groupId});
}
