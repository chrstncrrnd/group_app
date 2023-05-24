enum RequestType {
  follow,
  join;

  @override
  String toString() {
    switch (this) {
      case RequestType.follow:
        return "Follow";
      case RequestType.join:
        return "Join";
    }
  }
}

RequestType fromString(String value) {
  switch (value) {
    case "follow":
      return RequestType.follow;
    case "join":
      return RequestType.join;
    default:
      throw "Invalid request type";
  }
}

class Request {
  Request(
      {required this.requestType,
      required this.requestedAt,
      required this.requester,
      required this.groupRequested});

  final RequestType requestType;
  final String requester;
  final String groupRequested;
  final DateTime requestedAt;

  Request.fromJson({required Map<String, dynamic> json})
      : requestType = fromString(json["type"]),
        requestedAt = DateTime.parse(json["createdAt"]),
        requester = json["userId"],
        groupRequested = json["groupId"];
}
