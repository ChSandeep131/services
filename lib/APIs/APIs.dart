// ignore_for_file: avoid_print, file_names

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensechatapp/Models/message.dart';
import 'package:expensechatapp/Screens/ChatScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart';

import '../Models/chatUser.dart';

class APIs {
  //for authentication
  static FirebaseAuth auth = FirebaseAuth.instance;

  //for cloud firestore services
  static FirebaseFirestore firestore = FirebaseFirestore.instance;

  //for current user from authentication
  static User get user => auth.currentUser!;

  //for storing self information
  static late ChatUser me;

  //for push notification count
  static int notificationCount = 0;

  //for accessing firebase messageing
  static FirebaseMessaging fMessaging = FirebaseMessaging.instance;

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  //for getting firebase message token
  static Future<void> getFirebaseMessageToken(BuildContext context) async {
    await fMessaging.requestPermission();
    await fMessaging.getToken().then(
      (token) {
        if (token != null) {
          me.pushToken = token;
          print("pushToken: $token");
        }
      },
    );

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                me.id,
                me.name,
                channelDescription: me.about,
                color: Colors.blue,
                playSound: true,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        }
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (message.data.isNotEmpty) {
        String senderUserJson =
            message.data['user']; // Extract sender user information
        ChatUser senderUser = ChatUser.fromJson(jsonDecode(senderUserJson));

        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) =>
              ChatingScreen(user: senderUser), // Navigate to sender's screen
        ));
      }
    });
  }

  // for sending push notification
  static Future<void> sendPushNotification(
      ChatUser chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": me.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats",
        },
        "data": {
          "screen": "ChatingScreen",
          "user": jsonEncode(chatUser.toJson()),
        },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
                'key=AAAApXOnT8Y:APA91bFkcBEVM2N1D233xmcrDsSH1HjMzpZZaD8K5dUIRVE6aqqfLFkYYvxHTSVzzibxJQERsp-jgShObU031-o-h-HzyP2qjLx3dORc1eQnr-AUttdxFVYtcfcZD4VbeRIjmA5kPctA'
          },
          body: jsonEncode(body));
      print(body);
      print('Response status: ${res.statusCode}');
      print('Response body: ${res.body}');
      notificationCount++;
      print("Notification Count $notificationCount");
    } catch (e) {
      print('\nsendPushNotificationE: $e');
    }
  }

  //for checking whether user exits or not
  static Future<bool> userExists() async {
    return (await firestore.collection('users').doc(user.uid).get()).exists;
  }

  //for creating new user
  static Future<void> createUser() async {
    final time = DateTime.now().millisecondsSinceEpoch.toString();

    final chatUser = ChatUser(
        id: user.uid,
        name: user.displayName.toString(),
        email: user.email.toString(),
        about: "Hey, I'm using We Chat!",
        image: user.photoURL.toString(),
        createdAt: time,
        isOnline: false,
        lastActive: time,
        pushToken: '');

    return await firestore
        .collection('users')
        .doc(user.uid)
        .set(chatUser.toJson());
  }

  //for getting user info
  static Future<void> getSelfInfo(BuildContext context) async {
    await firestore.collection('users').doc(user.uid).get().then((user) async {
      if (user.exists) {
        me = ChatUser.fromJson(user.data()!);
        await getFirebaseMessageToken(context);
        APIs.updateActiveStatus(true);
        //print('my Data : ${user.data()}');
      } else {
        await createUser().then((value) => getSelfInfo(context));
      }
    });
  }

// for all users
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUsers() {
    return firestore
        .collection('users')
        .where('id', isNotEqualTo: user.uid)
        .snapshots();
  }

//for updating user information
  static Future<void> updateUserInfo() async {
    return await firestore.collection('users').doc(user.uid).update({
      'name': me.name,
      'about': me.about,
    });
  }

  // for getting specific user info
  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(
      ChatUser chatUser) {
    return firestore
        .collection('users')
        .where('id', isEqualTo: chatUser.id)
        .snapshots();
  }

  // update online or last active status of user
  static Future<void> updateActiveStatus(bool isOnline) async {
    firestore.collection('users').doc(user.uid).update({
      'is_online': isOnline,
      'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      'push_token': me.pushToken,
    });
  }

  // ************chat Releted Apis ******************

  static String getConversationID(String id) => user.uid.hashCode <= id.hashCode
      ? '${user.uid}_$id'
      : '${id}_${user.uid}';

  //for getting all messages of a specfic conversation from firestore
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessages(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .snapshots();
  }

  //get only last message of a specific chat
  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(
      ChatUser user) {
    return firestore
        .collection('chats/${getConversationID(user.id)}/messages/')
        .orderBy('sent', descending: true)
        .limit(1)
        .snapshots();
  }

  // for sending messages
  static Future<void> sendMessage(ChatUser chatUser, String msg) async {
    final time = DateTime.now().microsecondsSinceEpoch.toString();
    final Gmessage message = Gmessage(
      toId: chatUser.id,
      msg: msg,
      read: "",
      type: Type.text,
      sent: time,
      fromId: user.uid,
    );

    final ref = firestore
        .collection("chats/${getConversationID(chatUser.id)}/messages/");
    await ref
        .doc(time)
        .set(message.toJson())
        .then((value) => sendPushNotification(chatUser, msg));
  }
}
