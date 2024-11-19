import 'firebase_options.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_universities.dart';
import 'screens/subsystems_page.dart';
import 'models/university.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

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

Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  University? selectedUniversity = await _getSelectedUniversity(); // Obtener la universidad guardada

  // Inicializar zonas horarias
  tz.initializeTimeZones(); // Inicializa las zonas horarias
  tz.setLocalLocation(tz.getLocation('America/Santiago')); // O la ciudad que corresponda

  final String timeZoneName = DateTime.now().timeZoneName;
  print('Zona horaria del dispositivo: $timeZoneName');
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  await requestNotificationPermission();
  
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
