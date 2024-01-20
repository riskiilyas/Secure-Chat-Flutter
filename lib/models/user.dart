import 'dart:ui';

import 'package:secure_chat_demo/helper.dart';

class User {
  User({
    required this.id,
    required this.username,
    required this.publicKey,
  });

  User.fromJson(dynamic json) {
    id = json['id'];
    username = json['username'];
    publicKey = json['publicKey'];
  }

  late String id;
  late String username;
  late String publicKey;
  final Color color = userColors.random();

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['username'] = username;
    map['publicKey'] = publicKey;
    return map;
  }
}
