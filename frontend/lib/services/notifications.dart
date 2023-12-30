import 'package:cloud_functions/cloud_functions.dart';
import 'package:groopo/models/request.dart';

Future<void> acceptRequest(
    {required String userId,
    required String groupId,
    required RequestType requestType}) async {
  FirebaseFunctions.instance.httpsCallable("acceptRequest").call({
    "userId": userId,
    "groupId": groupId,
    "type": requestType.toString().toLowerCase()
  });
}

Future<void> denyRequest(
    {required String userId,
    required String groupId,
    required RequestType requestType}) async {
  FirebaseFunctions.instance.httpsCallable("denyRequest").call({
    "userId": userId,
    "groupId": groupId,
    "type": requestType.toString().toLowerCase()
  });
}
