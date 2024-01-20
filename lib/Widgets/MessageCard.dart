// ignore_for_file: file_names

import 'package:expensechatapp/APIs/APIs.dart';
import 'package:expensechatapp/Helper/myDateTime.dart';
import 'package:expensechatapp/Models/message.dart';
import 'package:flutter/material.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});

  final Gmessage message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    return APIs.user.uid == widget.message.fromId
        ? _redMessage()
        : _greyMessage();
  }

  Widget _greyMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: const BoxDecoration(
              color: Color.fromARGB(31, 70, 69, 69),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                topLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Text(widget.message.msg),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 19),
          child: Text(MyDateUtil.getFormattedTime(
              context: context, time: widget.message.sent)),
        ),
      ],
    );
  }

  Widget _redMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const SizedBox(
              width: 10,
            ),
            const Icon(
              Icons.done_all,
              color: Colors.blue,
              size: 20,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent)),
          ],
        ),
        Flexible(
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            // margin: const EdgeInsets.only(left: 10, right: 70),
            decoration: const BoxDecoration(
              color: Color.fromARGB(31, 251, 3, 3),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                topRight: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Text(widget.message.msg),
          ),
        ),
      ],
    );
  }
}
