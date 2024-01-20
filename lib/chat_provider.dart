import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:secure_chat_demo/models/User.dart';
import 'package:secure_chat_demo/rsa_helper.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'models/chat.dart';

class ChatProvider with ChangeNotifier {
  io.Socket? _socket;
  final List<Chat> chats = [];
  final List<User> onlineUsers = [];
  late RSAPrivateKey _privateKey;
  late RSAPublicKey _publicKey;
  String userId = '';
  bool? isConnected;
  String? username;

  Future<void> generateRsaKeys() async {
    AsymmetricKeyPair<PublicKey, PrivateKey> rsa =
        await RsaKeyHelper.computeRSAKeyPair();
    _privateKey = rsa.privateKey as RSAPrivateKey;
    _publicKey = rsa.publicKey as RSAPublicKey;
  }

  void initSocket({required String username}) async {
    this.username = username;

    await generateRsaKeys();
    String publicKeyString = RsaKeyHelper.encodePublicKeyToPemPKCS1(_publicKey);

    _socket = io.io(
        'http://192.168.100'
        '.123:3000?publicKey=$publicKeyString&username=${this.username}',
        <String, dynamic>{
          'transports': ['websocket'],
        });

    _socket!.on('chat', (data) {
      final chat = ReceivedChat.fromJson(data);

      final decryptedChat =
          RsaKeyHelper.decryptWithPrivateKey(chat.message, _privateKey);

      print('Received Message\nMessage: ${chat.message}\nDecrypted Message: '
          '$decryptedChat');
      chats.add(ReceivedChat(senderId: chat.senderId, message: decryptedChat));
      notifyListeners();
    });

    _socket!.on('disconnect', (_) {
      chats.clear();
      onlineUsers.clear();
      isConnected = false;
      notifyListeners();
      this.username = null;
    });

    _socket!.on('userConnected', (_) {
      onlineUsers.add(User.fromJson(_));
      notifyListeners();
    });

    _socket!.on('userDisconnected', (_) {
      final id = _['id'];
      onlineUsers.removeWhere((user) => user.id == id);
      notifyListeners();
    });

    _socket!.on('online_users', (_) {
      onlineUsers.clear();

      for (var user in _) {
        onlineUsers.add(User.fromJson(user));
      }

      notifyListeners();
    });

    _socket!.on('welcome', (_) {
      userId = _['sessionId'];
      isConnected = true;
    });

    _socket!.connect();
  }

  void sendMessage(String message, String publicKey, String userReceiverId) {
    final userPublicKey = RsaKeyHelper.parsePublicKeyFromPem(publicKey);

    final encryptedMsg =
        RsaKeyHelper.encryptWithPublicKey(message, userPublicKey);

    print('Send Message\nMessage: $message\nEncrypted Message: $encryptedMsg');

    final sendChat =
        SendChat(receiverId: userReceiverId, message: encryptedMsg);

    chats.add(SendChat(receiverId: userReceiverId, message: message));
    _socket!.emit('chat', sendChat.toJson());
    notifyListeners();
  }

  @override
  void dispose() {
    _socket?.dispose();
    super.dispose();
  }

  List<User> sortedUsers() {
    List<User> sorted = [];


    for (var _ in chats) {
      if (_ is ReceivedChat) {
        final sender = onlineUsers.where((u) => u.id == _.senderId).firstOrNull;
        if (sender == null) continue;
        if (!sorted.contains(sender)) {
          sorted.add(sender);
        }
      }
    }

    for (var _ in onlineUsers) {
      if(!sorted.contains(_)) sorted.add(_);
    }

    return sorted;
  }

  List<Chat> readChats(User user) {
    final userChats = chats.where((_) {
      if (_ is SendChat) return _.receiverId == user.id;
      if (_ is ReceivedChat) return _.senderId == user.id;
      return false;
    }).toList();

    return userChats;
  }

  void checkAllRead(User user) {
    final userChats = readChats(user);
    int newChatCtr = 0;
    for (var _ in userChats) {
      if (_ is ReceivedChat) {
        if (!_.isRead) {
          _.isRead = true;
          newChatCtr++;
        }
      }
    }

    if (newChatCtr > 0) {
      notifyListeners();
    }
  }
}
