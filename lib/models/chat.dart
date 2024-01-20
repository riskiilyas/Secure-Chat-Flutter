sealed class Chat {}

class ReceivedChat extends Chat {
  ReceivedChat({
    required this.senderId,
    required this.message,
  });

  ReceivedChat.fromJson(dynamic json) {
    senderId = json['senderId'];
    message = json['message'];
  }

  late String senderId;
  late String message;
  bool isRead = false;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['senderId'] = senderId;
    map['message'] = message;
    return map;
  }
}


class SendChat extends Chat{
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
