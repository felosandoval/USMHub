import 'firebase_options.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_universities.dart';
import 'screens/subsystems_page.dart';
import 'models/university.dart';


Future<University?> _getSelectedUniversity() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? universityJson = prefs.getString('selectedUniversity');
  
  if (universityJson != null) {
    try {
      Map<String, dynamic> universityMap = jsonDecode(universityJson);
      return University.fromJson(universityMap);
    } catch (e) {
      print('Error decoding JSON: $e'); // Manejo de error
    }
  }
  return null; // Si no hay universidad guardada
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  University? selectedUniversity = await _getSelectedUniversity(); // Obtener la universidad guardada

  runApp(MyApp(selectedUniversity: selectedUniversity));
}

class MyApp extends StatelessWidget {
  final University? selectedUniversity;

  MyApp({this.selectedUniversity});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromARGB(255, 247, 173, 1),
        ),
      ),
      home: selectedUniversity != null 
          ? SubsystemsPage(university: selectedUniversity!) // Redirigir si hay universidad seleccionada
          : HomeUniversities(), // Mostrar HomeUniversities si no hay universidad seleccionada
    );
  }
}
