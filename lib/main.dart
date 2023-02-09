import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mrs_panipuri/screens/frontpage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MyApp();
  }
}

class _MyApp extends State {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {'/': (context) => const FrontPage()},
      initialRoute: '/',
    );
  }
}
