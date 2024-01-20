import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:secure_chat_demo/chat_provider.dart';
import 'package:secure_chat_demo/models/User.dart';
import 'package:secure_chat_demo/models/chat.dart';
import 'package:secure_chat_demo/widgets/me_chat_widget.dart';
import 'package:secure_chat_demo/widgets/response_chat_widget.dart';

class ChatPage extends StatelessWidget {
  final User user;
  final msgController = TextEditingController();

  ChatPage({Key? key, required this.user}) : super(key: key);

  _checkAllRead(BuildContext context, User user) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if(!context.mounted) return;
      final provider = context.read<ChatProvider>();

      provider.checkAllRead(user);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: -8,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            CircleAvatar(
              foregroundColor: Colors.white,
              backgroundColor: user.color,
              child: Text(
                user.username[0],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(
              width: 12,
            ),
            Expanded(
                child: Text(
              user.username,
              overflow: TextOverflow.ellipsis,
            )),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(
                    "https://i.pinimg.com/originals/8f/ba/cb/8fbacbd464e996966eb9d4a6b7a9c21e.jpg"),
                fit: BoxFit.fill)),
        child: Consumer<ChatProvider>(
          builder: (context, provider, w) {
            final userChats = provider.readChats(user);
            _checkAllRead(context, user);
            return Column(
              children: <Widget>[
                Flexible(
                    child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView.builder(
                      itemCount: userChats.length,
                      itemBuilder: (context, i) {
                        final chat = userChats[i];
                        if (chat is SendChat) {
                          return MeChatWidget(
                              username: 'You',
                              msg: chat.message,
                              time: DateTime.now().toIso8601String());
                        } else if (chat is ReceivedChat) {
                          return ResponseChatWidget(
                              username: user.username,
                              msg: chat.message,
                              time: DateTime.now().toIso8601String());
                        }
                        return const SizedBox();
                      }),
                )),
                Row(children: <Widget>[
                  Flexible(
                      child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0, vertical: 8.0),
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(primaryColor: Colors.white),
                      child: TextField(
                        controller: msgController,
                        decoration: const InputDecoration(
                          hintText: "Type a message",
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                    ),
                  )),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor,
                    ),
                    child: IconButton(
                        icon: const Icon(
                          Icons.send_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          if (msgController.text.isEmpty) return;
                          provider.sendMessage(
                              msgController.text, user.publicKey, user.id);
                          msgController.clear();
                        }),
                  )
                ])
              ],
            );
          },
        ),
      ),
    ); //modified
  }
}
