import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:todoapp/home_page.dart';
import 'package:todoapp/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initializing Hive
  await Hive.initFlutter();

  // Open Box
  var box = await Hive.openBox('dataBox');

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => Placehold())],
      child: const MyApp(),
    ),
  );
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
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
