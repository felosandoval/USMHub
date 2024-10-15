import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'calendar_page.dart';
import 'ranking_page.dart';
import 'site_detail_page.dart';

import '../models/subsystem.dart';
import '../services/calculate_average_rating.dart';

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
        'Generar certificado alumno regular',
        'Ver resumen académico',
        'Ver planes de carrera',
      ],
      ratings: [],
    ),
    Subsystem(
      id: 2,
      name: 'Aula',
      url: 'https://aula.usm.cl',
      details: 'Sistema de gestión de aprendizaje.',
      procedures: [
        'Participar en foros',
        'Responder foros',
        'Entregar tareas',
        'Ver calificaciones',
        'Materiales de curso',
        'Revisar tareas',
      ],
      ratings: [],
    ),
    Subsystem(
      id: 3,
      name: 'Autoservicio',
      url: 'https://autoservicio.usm.cl',
      details: 'Portal de autoservicio institucional.',
      procedures: [
        'Pagar en línea',
        'Revisar estado de cuenta',
        'Pagos ayudantía',
        'Pagar deudas',
        'Cambiar cuenta bancaria',
      ],
      ratings: [],
    ),
    Subsystem(
      id: 4,
      name: 'Sireb',
      url: 'https://sireb.usm.cl',
      details: 'Sistema de .',
      procedures: [
        'Declaración de Antecedentes Socioeconómicos (DAS)',
        'postulación a Becas USM',
        'Renovación de Fondo Solidario Crédito Universitario',
        'Reservar hora médico',
        'Reservar hora kinesiólogo',
        'Reservar hora asistente social',
      ],
      ratings: [],
    ),
    Subsystem(
      id: 5,
      name: 'Casino',
      url: 'https://casino.usm.cl',
      details: 'Sistema de Casino de Alimentación USM.',
      procedures: [
        'Reserva de menú',
        'Mis reservas',
        'Mis consumos',
      ],
      ratings: [],
    ),
    Subsystem(
      id: 6,
      name: 'Gitlab DINF',
      url: 'https://gitlab.inf.utfsm.cl/',
      details: 'sistema de control de versiones y seguimiento de cambios de un proyecto del departamento de informática.',
      procedures: [
        'Gestionar versiones de proyectos',
        'Subir proyectos a internet',
        'Colaborar entre miembros de proyectos',
      ],
      ratings: [],
    ),
    Subsystem(
      id: 7,
      name: 'Gitlab Labcom',
      url: 'https://gitlab.labcomp.cl/',
      details: 'sistema de control de versiones y seguimiento de cambios de un proyecto del laboratorio de computación.',
      procedures: [
        'Gestionar versiones de proyectos',
        'Subir proyectos a internet',
        'Colaborar entre miembros de proyectos',
      ],
      ratings: [],
    ),
    Subsystem(
      id: 8,
      name: 'Asuntos Internacionales',
      url: 'https://oai.usm.cl/',
      details: 'Sistema de la oficina de asuntos internacionales.',
      procedures: [
        'Asuntos internacionales',
        'Información de intercambio',
        'Becas pasantía',
      ],
      ratings: [],
    ),
    Subsystem(
      id: 9,
      name: 'Minuta',
      url: 'https://vrea.usm.cl/minuta-alimentacion/',
      details: 'Sistema que contiene las minutas de alimentación para los campus y sedes de la Universidad',
      procedures: [
        'Revisar almuerzos',
      ],
      ratings: [],
    ),
    Subsystem(
      id: 10,
      name: 'Trabaja con nosotros',
      url: 'https://usm.hiringroom.com/jobs',
      details: 'Plataforma donde se publican vacantes laborales y se pueden postular a empleos en la Universidad',
      procedures: [
        'Publicación de vacantes laborales',
        'Buscar empleos',
        'Postular a empleos',
        'Buscar trabajos',
      ],
      ratings: [],
    ),
    Subsystem(
      id: 11,
      name: 'USM X',
      url: 'https://usmx.cl/',
      details: 'Plataforma de cursos abiertos en línea.',
      procedures: [
        'Inscripción en cursos online.',
        'Acceso a material educativo digital.',
        'Solicitud de certificaciones al finalizar cursos.',
        'Participación en programas de formación profesional.',
      ],
      ratings: [],
    ),
    Subsystem(
      id: 12,
      name: 'Directorio',
      url: 'https://www.directorio.usm.cl/',
      details: 'Información respecto a funcionarios de la universidad.',
      procedures: [
        'Buscar funcionario',
        'Buscar número de profesores',
        'Buscar autoridades',
      ],
      ratings: [],
    ),
    Subsystem(
      id: 13,
      name: 'Validador de Documentos',
      url: 'https://validaciondocumentos.usm.cl/',
      details: 'Sistema de verificación de documentos emitidos por la Universidad.',
      procedures: [
        'Verificar certificados',
        'Verificar documentos',
        ],
      ratings: [],
    ),
    Subsystem(
      id: 14,
      name: 'Biblioteca Digital',
      url: 'https://bibliotecadigital.usm.cl/',
      details: 'Plataforma de la Universidad que ofrece acceso a recursos académicos en línea, como libros, artículos, y tesis, para estudiantes y profesores.',
      procedures: [
        'Acceso a libros y artículos en formato digital.',
        'Descarga de tesis y publicaciones académicas.',
        'Búsqueda y consulta de recursos especializados.',
        'Préstamo de libros electrónicos.',
        ],
      ratings: [],
    ),
    // Subsystem(
    //   id: ,
    //   name: '',
    //   url: '',
    //   details: '',
    //   procedures: [
    //     '',
    //     '',
    //     ],
    //   ratings: [],
    // ),
  ];
  List<Subsystem> filteredSites = [];
  ValueNotifier<bool> _isTextPresent = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    filteredSites = allSites;
    _initializeData();
    _sortSitesByName(); // Ordenar sitios alfabéticamente al iniciar
    textEditingController.addListener(() {
      _isTextPresent.value = textEditingController.text.isNotEmpty;
    });
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
                    hintText: 'Buscar sitios, servicios o trámites...',
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
