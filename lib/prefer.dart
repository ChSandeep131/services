import 'package:expensechatapp/pre.dart';
import 'package:flutter/material.dart';

class Preference extends StatelessWidget {
  const Preference({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("hbdhsgdw"),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Pre()));
            },
            child: Text("clickkkkk")),
      ),
    );
  }
}