import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_chat_demo/chat_page.dart';
import 'package:secure_chat_demo/chat_provider.dart';
import 'package:secure_chat_demo/models/chat.dart';

import 'models/User.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  _initSocket(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (context.mounted) {
        final provider = context.read<ChatProvider>();
        final status = provider.isConnected;
        if (status != true) {
          if (status == false) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Disconnected!')));
          }


          if (provider.username == null) {
            provider.username='';
            await _showUsernameDialog(context);
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _initSocket(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            SizedBox(
              height: 32,
              child: Image.asset(
                'assets/logo.png',
              ),
            ),
            const SizedBox(
              width: 16,
            ),
            const Text(
              'Secure Chat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Consumer<ChatProvider>(builder: (context, provider, w) {
        final users = provider.sortedUsers();


        if (users.isEmpty) {
          return const Center(
            child: Text(
              'No Online Users...',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, i) {
              final chatCounters =
                  generateChatCounts(provider.chats, users[i].id);
              return Stack(
                children: [
                  Column(
                    children: [
                      const Divider(height: 10),
                      ListTile(
                        leading: CircleAvatar(
                          foregroundColor: Colors.white,
                          backgroundColor: users[i].color,
                          child: Text(
                            users[i].username[0],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          users[i].username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Container(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            getRecentMessage(provider, users[i]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14),
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  ChatPage(user: users[i]),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  chatCounters == 0
                      ? const SizedBox()
                      : Positioned(
                          top: 12,
                          right: 8,
                          child: Material(
                            borderRadius: BorderRadius.circular(64),
                            color: Colors.redAccent.withOpacity(0.8),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                chatCounters.toString(),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20),
                              ),
                            ),
                          ))
                ],
              );
            });
      }),
    );
  }

  String getRecentMessage(ChatProvider provider, User user) {
    final chat = provider.chats
        .where((_) {
          try {
            final received = _ as ReceivedChat;
            return received.senderId == user.id;
          } catch (e) {
            return false;
          }
        })
        .map((e) => e as ReceivedChat)
        .lastOrNull;

    if (chat != null) {
      return chat.message;
    } else {
      return '';
    }
  }

  Future<void> _showUsernameDialog(BuildContext context) async {
    final provider = context.read<ChatProvider>();
    final TextEditingController usernameController = TextEditingController();
    final random = Random.secure().nextInt(99999);

    usernameController.text = 'User$random';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(
              child: Text(
            'Enter Username',
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          contentPadding: const EdgeInsets.all(16),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                if (usernameController.text.isEmpty) return;
                provider.initSocket(username: usernameController.text);
                Navigator.pop(context);
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  int generateChatCounts(List<Chat> chats, String id) {
    return chats.where((_) {
      if (_ is ReceivedChat) {
        return !_.isRead && _.senderId == id;
      }
      return false;
    }).length;
  }

  Color randomColor() => Color.fromARGB(255, Random.secure().nextInt(255),
      Random.secure().nextInt(255), Random.secure().nextInt(255));
}
