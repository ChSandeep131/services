// ignore_for_file: file_names

import 'package:expensechatapp/APIs/APIs.dart';
import 'package:expensechatapp/ExpensesRelated/ExpensesScreen/Expenses.dart';
import 'package:expensechatapp/Screens/MyHomeScreen.dart';
import 'package:expensechatapp/Screens/ProfileScreen.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int index = 0;
  late Future<void> _initialization;
  late List<Widget> screens;

  @override
  void initState() {
    super.initState();
    // Initialize the future in initState
    _initialization = APIs.getSelfInfo(context).then((_) {
      // Once initialization is complete, update the state with ProfileScreen
      setState(() {
        screens = [
          const HomeScreen(),
          const ExpensesScreen(),
          ProfileScreen(user: APIs.me),
        ];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: FloatingActionButton(
          onPressed: () async {},
          child: Text("${APIs.notificationCount}"),
        ),
      ),
      body: FutureBuilder(
        // Use the initialized future
        future: _initialization,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while waiting for initialization
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Handle initialization errors
            return const Center(child: Text('Error initializing user data'));
          } else {
            // Once initialization is complete, show the appropriate screen
            return screens[index];
          }
        },
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
            indicatorColor: Colors.blue.shade100,
            labelTextStyle: const MaterialStatePropertyAll(
                TextStyle(fontSize: 14, fontWeight: FontWeight.bold))),
        child: NavigationBar(
          height: 60,
          selectedIndex: index,
          onDestinationSelected: (index) => setState(() {
            this.index = index;
          }),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.chat_sharp),
              label: 'chats',
            ),
            NavigationDestination(
              icon: ImageIcon(
                AssetImage("images/spending.png"),
                color: Colors.brown,
                size: 24,
              ),
              label: 'Expenses',
            ),
            NavigationDestination(
              icon: Icon(Icons.person),
              label: 'profile',
            ),
          ],
        ),
      ),
    );
  }
}
