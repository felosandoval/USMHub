import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:table_calendar/table_calendar.dart';
//import 'package:dropdown_search/dropdown_search.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // PENDIENTE: Inicializar los widgets
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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue, // Color base para generar la paleta
        ),
      ),
      title: 'USM Hub',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class Subsystem {
  final int id;
  final String name;
  final String url;
  final String details;
  final List<String> procedures; // Nuevo campo para trámites

  Subsystem({required this.id, required this.name, required this.url, required this.details, required this.procedures});
}

class _HomePageState extends State<HomePage> {
  List<Subsystem> allSites = [
    Subsystem(
      id: 1,
      name: 'Siga',
      url: 'https://siga.usm.cl',
      details: 'Sistema de información y gestión académica.',
      procedures: [
        'Revisar horario',
        'Inscribir ramos',
        'Generar certificados de alumno regular',
        'Ver resumen académico',
      ],
    ),
    
    Subsystem(
      id: 2,
      name: 'Aula',
      url: 'https://aula.usm.cl',
      details: 'Accede a materiales de curso, foros y tareas.',
      procedures: [
        'Participar en foros',
        'Entregar tareas',
        'Ver calificaciones',
      ],
    ),
    
    Subsystem(
      id: 3,
      name: 'Autoservicio',
      url: 'https://autoservicio.usm.cl',
      details: 'Accede a materiales de curso, foros y tareas.',
      procedures: [
        'Participar en foros',
        'Entregar tareas',
        'Ver calificaciones',
      ],
    ),

    Subsystem(
      id: 4,
      name: 'Sireb',
      url: 'https://sireb.usm.cl',
      details: 'A.',
      procedures: [
        'A',
        'A',
        'A',
      ],
    ),

    Subsystem(
      id: 5,
      name: 'Casino',
      url: 'https://casino.usm.cl',
      details: 'A.',
      procedures: [
        'A',
        'A',
        'A',
      ],
    ),

    Subsystem(
      id: 6,
      name: 'GitLab DINF',
      url: 'https://gitlab.inf.utfsm.cl/',
      details: 'A.',
      procedures: [
        'A',
        'A',
        'A',
      ],
    ),

    Subsystem(
      id: 7,
      name: 'GitLab LabComp',
      url: 'https://gitlab.labcomp.cl/',
      details: 'A.',
      procedures: [
        'A',
        'A',
        'A',
      ],
    ),

    Subsystem(
      id: 8,
      name: 'Asuntos Internacionales',
      url: 'https://oai.usm.cl/',
      details: 'A.',
      procedures: [
        'A',
        'A',
        'A',
      ],
    ),

    // Subsystem(
    //   id: ,
    //   name: 'A',
    //   url: '',
    //   details: 'A.',
    //   procedures: [
    //     'A',
    //     'A',
    //     'A',
    //   ],
    // ),
  ];

  List<Subsystem> filteredSites = [];

  @override
  void initState() {
    super.initState();
    filteredSites = allSites; // Inicialmente muestra todos los sitios
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: 
          Text(
              'USM Hub',
              style: 
                GoogleFonts.roboto(
                  fontSize: 25
                ),
            ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => UniversityCalendar()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Buscador en tiempo real con margen lateral
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: TextField(
              onChanged: (text) {
                setState(() {
                  filteredSites = allSites.where((site) =>
                    site.name.toLowerCase().contains(text.toLowerCase())
                  ).toList();
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar sitios...',
                hintStyle: GoogleFonts.openSans(
                  fontSize: 17,
                  color: Colors.grey,  // Color del hint
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),  // Margen solo a los lados
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,  // Espacio horizontal entre las cards
                  mainAxisSpacing: 10.0,  // Espacio vertical entre las cards
                ),
                itemCount: filteredSites.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Colors.green.shade100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),  // Bordes redondeados
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SiteDetailPage(site: filteredSites[index]),
                          ),
                        );
                      },
                      child: Center(
                        child: Text(filteredSites[index].name),
                      ),
                    ),
                  );
                }
              ),
            ),
          ),
        ],
      )


    );
  }

  void _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('No se puede cargar la url: $url');
    }
  }
}

class UniversityCalendar extends StatefulWidget {
  @override
  _UniversityCalendarState createState() => _UniversityCalendarState();
}

class _UniversityCalendarState extends State<UniversityCalendar> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendario Universitario')),
      body: Column(
        children: [
          TableCalendar(
            focusedDay: _focusedDay,
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay; // PENDIENTE: Actualizar el día enfocado en el día seleccionado
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            eventLoader: (day) {
              // PENDIENTE: Cargar eventos aquí
              return []; // Retorna una lista de eventos para el día
            },
            calendarStyle: CalendarStyle(
              // Estilo del calendario
              selectedDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: HeaderStyle(
              // Estilo del encabezado
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
        ],
      ),
    );
  }
}

class SiteDetailPage extends StatelessWidget {
  final Subsystem site;

  SiteDetailPage({required this.site});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Información del sitio")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              site.name,
              style: GoogleFonts.roboto(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              site.details,
              style: GoogleFonts.roboto(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Trámites disponibles:',
              style: GoogleFonts.roboto(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 13),
            ...site.procedures.map((procedure) => Text(
              '• $procedure',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
            )).toList(),

            SizedBox(height: 40),
            Center(
              child: ElevatedButton(
                onPressed: () => _launchURL(site.url),
                child: Text('IR AL SITIO'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('No se puede cargar la url: $url');
    }
  }
}
