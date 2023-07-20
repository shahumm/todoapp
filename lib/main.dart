import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/home_page.dart';
import 'package:todoapp/intro_screen.dart';

bool nameAsked = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ask For Name Once
  final preferences = await SharedPreferences.getInstance();
  nameAsked = preferences.getBool('UserName') ?? true;

  // Initializing Hive
  await Hive.initFlutter();

  // Open Box
  var box = await Hive.openBox('dataBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFFD5B858),
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: nameAsked
          ? const UserName()
          : HomePage(userName: UserName.getUserName()),
      debugShowCheckedModeBanner: false,
    );
  }
}
