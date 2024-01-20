// ignore_for_file: file_names

import 'dart:io';
import 'dart:developer';

import 'package:expensechatapp/Screens/BottomNavigationBar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../APIs/APIs.dart';
import '../Helper/dialogs.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _handleGoogleSignIn() {
    //for showing progress bar
    Dialogs.showProgressBar(context);
    //for hiding progress bar
    _signInWithGoogle().then((user) async {
      Navigator.pop(context);
      if (user != null) {
        if ((await APIs.userExists())) {
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const MainPage()));
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const MainPage()));
          });
        }
      }
    });
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      log("\n _signInWithGoogle: $e");
      // ignore: use_build_context_synchronously
      Dialogs.showSnackbar(context, "Something went wrong (Check Internet!)");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to Expenses app"),
      ),
      body: Stack(
        children: [
          Positioned(
            top: 100,
            left: 100,
            width: 200,
            child: Image.asset("images/expense.png"),
          ),
          Positioned(
            bottom: 130,
            left: 19,
            width: 350,
            height: 60,
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(221, 28, 28, 28),
                    shape: const StadiumBorder()),
                onPressed: () {
                  _handleGoogleSignIn();
                },
                icon: Image.asset(
                  "images/google.png",
                  height: 30,
                ),
                label: const Text("Sign in with Google")),
          ),
        ],
      ),
    );
  }
}
