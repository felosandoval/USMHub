import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

//import 'package:dropdown_search/dropdown_search.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // PENDIENTE: Inicializar los widgets
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

Future<User?> signInWithGoogle() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
  return userCredential.user;
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
  final List<double> ratings; // Nuevo campo para calificaciones

  Subsystem({required this.id, required this.name, required this.url, required this.details, required this.procedures, required this.ratings});
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
      ratings: [],
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
      ratings: [],

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
      ratings: [],
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
      ratings: [],
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
      ratings: [],
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
      ratings: [],
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
      ratings: [],
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
      ratings: [],
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

class SiteDetailPage extends StatefulWidget {
  final Subsystem site;

  SiteDetailPage({required this.site});

  @override
  _SiteDetailPageState createState() => _SiteDetailPageState();
}

class _SiteDetailPageState extends State<SiteDetailPage> {
  double? _userRating;
  double _averageRating = 0.0;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _checkUserRating();
    }
  }

  void _checkUserRating() async {
    final doc = await FirebaseFirestore.instance
        .collection('ratings')
        .doc(widget.site.id.toString())
        .collection('userRatings')
        .doc(user!.uid)
        .get();

    if (doc.exists) {
      setState(() {
        _userRating = doc['rating'];
      });
    }

    _calculateAverageRating();
  }

  void _calculateAverageRating() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('ratings')
        .doc(widget.site.id.toString())
        .collection('userRatings')
        .get();

    if (snapshot.docs.isNotEmpty) {
      final totalRatings = snapshot.docs.map((doc) => doc['rating'] as double).reduce((a, b) => a + b);
      setState(() {
        _averageRating = totalRatings / snapshot.docs.length;
      });
    }
  }

  void _submitRating(double rating) async {
    await FirebaseFirestore.instance
        .collection('ratings')
        .doc(widget.site.id.toString())
        .collection('userRatings')
        .doc(user!.uid)
        .set({'rating': rating});

    _calculateAverageRating();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.site.name),
            SizedBox(width: 10),
            if (_averageRating > 0)
              Text(
                _averageRating.toStringAsFixed(1),
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.site.name,
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              widget.site.details,
              style: GoogleFonts.roboto(
                fontSize: 18,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Trámites disponibles:',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            ...widget.site.procedures.map((procedure) => Text(
              '• $procedure',
              style: TextStyle(fontSize: 18),
            )).toList(),
            SizedBox(height: 20),
            Text(
              'Calificar este sitio:',
              style: GoogleFonts.roboto(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            if (user != null) ...[
              RatingBar.builder(
                initialRating: _userRating ?? 0.0,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    _userRating = rating;
                  });
                  _submitRating(rating);
                },
              ),
              SizedBox(height: 20),
            ] else ...[
              ElevatedButton(
                onPressed: () async {
                  await signInWithGoogle();
                  _checkUserRating();
                },
                child: Text('Inicia sesión con Google para calificar'),
              ),
              SizedBox(height: 20),
            ],
            Center(
              child: ElevatedButton(
                onPressed: () => _launchURL(widget.site.url),
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
