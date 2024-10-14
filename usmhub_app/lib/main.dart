import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3:true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 247, 173, 1),
        ),
      ),
      title: 'USM Hub',
      home: HomePage(),
    );
  }
}
