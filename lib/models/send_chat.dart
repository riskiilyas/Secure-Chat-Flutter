class SendChat {
  SendChat({
    required this.receiverId,
    required this.message,
  });

  SendChat.fromJson(dynamic json) {
    receiverId = json['receiverId'];
    message = json['message'];
  }

  late String receiverId;
  late String message;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['receiverId'] = receiverId;
    map['message'] = message;
    return map;
  }
}
