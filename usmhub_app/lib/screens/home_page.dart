import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Esta es la importación necesaria
import '../models/subsystem.dart';
import 'calendar_page.dart';
import 'ranking_page.dart';
import 'site_detail_page.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/calculate_average_rating.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();
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
    // añade más sitios aquí...
  ];
  List<Subsystem> filteredSites = [];
  ValueNotifier<bool> _isTextPresent = ValueNotifier<bool>(false);
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    filteredSites = allSites;
    _initializeData();
    _sortSitesByName(); // Ordenar sitios alfabéticamente al iniciar
    textEditingController.addListener(() {
      _isTextPresent.value = textEditingController.text.isNotEmpty;
    });
    _checkAuthentication();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await calculateAverageRatings(allSites);
    setState(() {
      // Actualiza el estado si es necesario
    });
  }

  void _sortSitesByName() {
    setState(() {
      filteredSites.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  void _checkAuthentication() {
    _authService.authStateChanges.listen((User? user) {
      setState(() {
        _isLoggedIn = user != null;
      });
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
          if (_isLoggedIn) // Solo mostrar si el usuario está logeado
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
