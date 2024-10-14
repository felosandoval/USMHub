import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'screens/calendar_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

Future<User?> signInWithGoogle(BuildContext context, Function callback) async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  if (googleUser == null) {
    _showMessage(context, 'Por favor, para calificar, seleccione su cuenta');
    return null;
  }

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final AuthCredential credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
  
  // Llama al callback para actualizar el estado
  callback();
  return userCredential.user;
}

Future<void> signOutWithGoogle() async {
  await GoogleSignIn().signOut();
  await FirebaseAuth.instance.signOut();
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
    ),
  );
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

class Subsystem {
  final int id;
  final String name;
  final String url;
  final String details;
  final List<String> procedures;
  final List<double> ratings;
  double _averageRating;

  Subsystem({
    required this.id,
    required this.name,
    required this.url,
    required this.details,
    required this.procedures,
    required this.ratings,
    double? averageRating,
  }) : _averageRating = averageRating ?? 0.0;

  double get averageRating => _averageRating;

  set averageRating(double value) {
    _averageRating = value;
  }

  Future<void> fetchAndRecalculateAverageRating() async {
    // Ajustar la colección y documento basado en el `id` de cada `Subsystem`
    final snapshot = await FirebaseFirestore.instance
      .collection('reseñas')
      .doc(name.toString())
      .collection('userRatings')
      .get();

    final newRatings = snapshot.docs.map((doc) => doc['valoración'] as double).toList();

    if (newRatings.isNotEmpty) {
      ratings.clear();
      ratings.addAll(newRatings);
      _averageRating = ratings.reduce((a, b) => a + b) / ratings.length;
    }
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController textEditingController = TextEditingController();
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
        'Ver planes de carrera',
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
        'Pagos ayudantía',
        'Pagar deudas'

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
        'Ver alimentos',
        'Ver almuerzos',
        'A',
      ],
      ratings: [],
    ),
    Subsystem(
      id: 6,
      name: 'Gitlab DINF',
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
      name: 'Gitlab Labcom',
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
    Subsystem(
      id: 9,
      name: 'Minuta',
      url: 'https://vrea.usm.cl/minuta-alimentacion/',
      details: '.',
      procedures: [
        'A',
        'A',
        'A',
      ],
      ratings: [],
    ),
    Subsystem(
      id: 10,
      name: 'Trabaja con nosotros',
      url: 'https://usm.hiringroom.com/jobs',
      details: 'A.',
      procedures: [
        'A',
        'A',
        'A',
      ],
      ratings: [],
    ),
    Subsystem(
      id: 11,
      name: 'USM X',
      url: 'https://usmx.cl/',
      details: 'Plataforma de cursos abiertos en línea.',
      procedures: [
        'A',
        'A',
        'A',
      ],
      ratings: [],
    ),
    Subsystem(
      id: 12,
      name: 'Directorio',
      url: 'https://www.directorio.usm.cl/',
      details: 'A.',
      procedures: [
        'A',
        'A',
        'A',
      ],
      ratings: [],
    ),
  ];
  List<Subsystem> filteredSites = [];
  double _averageRating = 0.0;
  ValueNotifier<bool> _isTextPresent = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    filteredSites = allSites;
    _calculateAverageRatings();
    _sortSitesByName();  // Ordenar sitios alfabéticamente al iniciar

    textEditingController.addListener(() {
      _isTextPresent.value = textEditingController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> _calculateAverageRating(Subsystem site) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reseñas')
        .doc(site.name)
        .collection('userRatings')
        .get();
    if (snapshot.docs.isNotEmpty) {
      final totalRatings = snapshot.docs.map((doc) => doc['valoración'] as double).reduce((a, b) => a + b);
      if (mounted) {
        setState(() {
          _averageRating = totalRatings / snapshot.docs.length;
          site.averageRating = _averageRating;  // Asigna el promedio de valoración al sitio
        });
      }
    }
  }

  Future<void> _calculateAverageRatings() async {
    for (var site in allSites) {
      await _calculateAverageRating(site);
    }
  }

  void _sortSitesByName() {
    setState(() {
      filteredSites.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'USM Hub',
          style: GoogleFonts.roboto(fontSize: 25),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => CalendarPage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () async {
              for (var site in allSites) {
                await site.fetchAndRecalculateAverageRating();
              }
              setState(() {});
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RankingsPage(sites: allSites),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
            child: ValueListenableBuilder(
              valueListenable: _isTextPresent,
              builder: (context, isTextPresent, child) {
                return TextField(
                  controller: textEditingController,
                  onChanged: (text) {
                    setState(() {
                      filteredSites = allSites.where((site) {
                        final lowerCaseQuery = text.toLowerCase();
                        final matchesName = site.name.toLowerCase().contains(lowerCaseQuery);
                        final matchesProcedures = site.procedures.any((procedure) => procedure.toLowerCase().contains(lowerCaseQuery));
                        return matchesName || matchesProcedures;
                      }).toList();
                      _sortSitesByName();  // Ordenar cada vez que se filtra
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Buscar sitios...',
                    hintStyle: GoogleFonts.openSans(
                      fontSize: 17,
                      color: Colors.grey,
                    ),
                    suffixIcon: isTextPresent
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                filteredSites = allSites;
                                _sortSitesByName();  // Ordenar cuando se limpia el filtro
                              });
                              textEditingController.clear();
                            },
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                ),
                itemCount: filteredSites.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: Color.fromARGB(199, 0, 75, 133),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
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
                        child: Text(
                          filteredSites[index].name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
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
  int _totalReviews = 0;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _checkUserRating();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
          _checkUserRating();
        });
      }
    });
  }

  void _checkUserRating() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final doc = await _retryOnException(() async {
          return await FirebaseFirestore.instance
            .collection('reseñas')
            .doc(widget.site.name)
            .collection('userRatings')
            .doc(user.email)
            .get();
        });

        if (doc.exists) {
          setState(() {
            _userRating = doc['valoración'];
          });
        } else {
          setState(() {
            _userRating = null;
          });
        }

        _calculateAverageRating();
      } catch (e) {
        print('Error al obtener el rating del usuario: $e');
      }
    } else {
      print('El usuario no ha iniciado sesión.');
    }
  }

  Future<T> _retryOnException<T>(Future<T> Function() action, {int retries = 5}) async {
    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        return await action();
      } catch (e) {
        if (attempt == retries - 1) {
          rethrow;
        }
        await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
      }
    }
    throw Exception('Failed after $retries attempts');
  }

  Future<int> _getTotalReviews() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reseñas')
        .doc(widget.site.name)
        .collection('userRatings')
        .get();

    return snapshot.docs.length;
  }

  void _calculateAverageRating() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('reseñas')
        .doc(widget.site.name)
        .collection('userRatings')
        .get();

    if (snapshot.docs.isNotEmpty) {
      final totalRatings = snapshot.docs.map((doc) => doc['valoración'] as double).reduce((a, b) => a + b);
      if (mounted) {
        setState(() {
          _averageRating = totalRatings / snapshot.docs.length;
          _totalReviews = snapshot.docs.length;
        });
      }
    }
  }

  void _submitRating(double rating) async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      await FirebaseFirestore.instance
        .collection('reseñas')
        .doc(widget.site.name)
        .collection('userRatings')
        .doc(currentUser.email)
        .set({'valoración': rating});

      _calculateAverageRating();
    } else {
      print('El usuario no ha iniciado sesión.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("Información del sitio"),
            SizedBox(width: 10),
            
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.site.name,
                style: GoogleFonts.roboto(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.visible,
                maxLines: null,
                softWrap: true,
              ),
              SizedBox(height: 5), // Espacio entre el nombre y las reseñas
              if (_averageRating > 0)
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber, // Puedes cambiar el color si prefieres otro
                    ),
                    SizedBox(width: 5),
                    Text(
                      _averageRating.toStringAsFixed(1),
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 5),
                    FutureBuilder<int>(
                      future: _getTotalReviews(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text(
                            '(cargando reseñas)',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          );
                        } else if (snapshot.hasError) {
                          return Text(
                            '($_totalReviews reseñas)', // Mostrar el total de reseñas que tenemos
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          );
                        } else {
                          return Text(
                            '(${snapshot.data ?? _totalReviews} reseñas)', // Mostrar el total de reseñas del snapshot o el total que tenemos
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          );
                        }
                      },
                    ),
                  ],
                ),
            ],
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
              // RESEÑAS (5 ESTRELLAS)
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                    SizedBox(width: 10), // Espacio entre las estrellas y el texto
                    Text(
                      _userRating?.toStringAsFixed(1) ?? '0.0',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),
              // Botón de cerrar sesión
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await signOutWithGoogle();
                    setState(() {});
                    _checkUserRating();
                  },
                  child: Text('Cerrar sesión'),
                ),
              ),
            ] else ...[
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await signInWithGoogle(context, () {
                      setState(() {
                        _checkUserRating();
                      });
                    });
                  },
                  child: Text('Inicia sesión con Google para calificar'),
                ),
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

class RankingsPage extends StatefulWidget {
  final List<Subsystem> sites;

  RankingsPage({required this.sites});

  @override
  _RankingsPageState createState() => _RankingsPageState();
}

class _RankingsPageState extends State<RankingsPage> {
  @override
  Widget build(BuildContext context) {
    // Ordena los sitios antes de construir la UI
    List<Subsystem> sortedSites = List.from(widget.sites);
    sortedSites.sort((a, b) => b.averageRating.compareTo(a.averageRating));

    return Scaffold(
      appBar: AppBar(title: Text('Rankings')),
      body: ListView.builder(
        itemCount: sortedSites.length,
        itemBuilder: (context, index) {
          final site = sortedSites[index];
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text('${index + 1}. ${site.name}'),
              subtitle: Text(
                site.averageRating == 0
                  ? 'Sin valoraciones'
                  : 'Average Rating: ${site.averageRating.toStringAsFixed(2)}',
              ),
              trailing: Icon(Icons.star, color: Colors.amber),
            ),
          );
        },
      ),
    );
  }
}
