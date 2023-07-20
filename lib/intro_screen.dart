import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/home_page.dart';

class UserName extends StatefulWidget {
  const UserName({super.key});

  @override
  State<UserName> createState() => _UserNameState();

  static String getUserName() {
    return _UserNameState.name.text;
  }
}

class _UserNameState extends State<UserName> {
  // Controller
  static final name = TextEditingController();

  void moveOn(context) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('UserName', false);

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => HomePage(userName: name.text),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text("Your name?"),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: name,
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              moveOn(context);
            },
            child: const Text('Next'),
          )
        ],
      ),
    );
  }
}
