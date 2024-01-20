// ignore_for_file: file_names

import 'package:expensechatapp/APIs/APIs.dart';
import 'package:expensechatapp/Helper/myDateTime.dart';
import 'package:expensechatapp/Models/chatUser.dart';
import 'package:expensechatapp/Models/message.dart';
import 'package:expensechatapp/Screens/ChatScreen.dart';
import 'package:flutter/material.dart';

class ChatUserCard extends StatefulWidget {
  final ChatUser chatUser;

  const ChatUserCard({super.key, required this.chatUser});

  @override
  State<ChatUserCard> createState() => _ChatUserCardState();
}

class _ChatUserCardState extends State<ChatUserCard> {
  Gmessage? _message;
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 04, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 0.5,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatingScreen(
                user: widget.chatUser,
              ),
            ),
          );
        },
        child: StreamBuilder(
          stream: APIs.getLastMessage(widget.chatUser),
          builder: (context, snapshot) {
            final data = snapshot.data?.docs;
            final list =
                data?.map((e) => Gmessage.fromJson(e.data())).toList() ?? [];
            if (list.isNotEmpty) _message = list[0];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Image.network(widget.chatUser.image),
              ),
              title: Text(widget.chatUser.name),
              subtitle: Text(
                  _message != null ? _message!.msg : widget.chatUser.about,
                  maxLines: 1),
              trailing: Text(MyDateUtil.getFormattedTime(
                  context: context,
                  time: _message != null
                      ? _message!.sent
                      : widget.chatUser.lastActive)),
            );
          },
        ),
      ),
    );
  }
}
