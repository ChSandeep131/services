import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class NotificaScreen extends StatefulWidget {
  const NotificaScreen({super.key});

  @override
  State<NotificaScreen> createState() => _NotificaScreenState();
}

class _NotificaScreenState extends State<NotificaScreen> {
  @override
  Widget build(BuildContext context) {
    final message = ModalRoute.of(context)!.settings.arguments as RemoteMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notification Screen"),
      ),
      body: Column(children: [
        Text(message.notification!.title.toString()),
        Text(message.notification!.body.toString()),
        //Text(message.notification!.title.toString()),
      ],),
    );
  }
}
