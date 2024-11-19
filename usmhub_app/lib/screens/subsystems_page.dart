import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'calendar_page.dart';
import 'ranking_page.dart';
import 'site_detail_page.dart';
import 'home_universities.dart';

import '../models/subsystem.dart';
import '../models/university.dart';
import '../services/calculate_average_rating.dart';

class SubsystemsPage extends StatefulWidget {
  final University university;

  SubsystemsPage({required this.university});

  @override
  _SubsystemsPageState createState() => _SubsystemsPageState();
}

class _SubsystemsPageState extends State<SubsystemsPage> {
  TextEditingController textEditingController = TextEditingController();
  List<Subsystem> allSites = [];
  List<Subsystem> filteredSites = [];
  List<Subsystem> pinnedSites = []; // Lista de sitios fijados
  ValueNotifier<bool> _isTextPresent = ValueNotifier<bool>(false);
  SharedPreferences? prefs; // Variable para SharedPreferences

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
    textEditingController.addListener(() {
      _isTextPresent.value = textEditingController.text.isNotEmpty;
    });
  }

  // Inicializa SharedPreferences y recarga sitios pineados
  Future<void> _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    await _refreshSites(); // Espera a que se carguen los sitios
    _loadPinnedSites(); // Cargar los sitios pinneados aquí
  }

  // Refresca los sitios en base a los datos de firebase
  Future<void> _refreshSites() async {
    final snapshot = await FirebaseFirestore.instance
      .collection('universities')
      .doc(widget.university.id.toString())
      .collection('subsystems').get();
    setState(() {
      allSites = snapshot.docs.map((doc) => Subsystem.fromJson(doc.data())).toList();
      filteredSites = List.from(allSites); // Copiar la lista completa
      _loadPinnedSites(); // Restaurar los sitios pinneados desde SharedPreferences
      _sortSitesByName();
      _reorderPinnedSites(); // Reordenar sitios fijados
      _initializeData();
    });
  }

  String _getPinnedSitesKey(String universityId) {
    return 'pinnedSites_$universityId';
  }


  // Cargar sitios pinneados desde SharedPreferences
  void _loadPinnedSites() {
    final key = _getPinnedSitesKey(widget.university.id.toString());
    final pinnedSiteIds = prefs?.getStringList(key) ?? [];
    
    setState(() {
      pinnedSites = allSites.where((site) {
        final siteId = site.id.toString(); // Convertir ID del sitio a String
        return pinnedSiteIds.contains(siteId);
      }).toList();
    });
  }


  // Guardar los sitios pinneados en SharedPreferences
  void _savePinnedSites() {
    final key = _getPinnedSitesKey(widget.university.id.toString());
    final pinnedSiteIds = pinnedSites.map((site) => site.id.toString()).toList();
    prefs?.setStringList(key, pinnedSiteIds);
  }

  Future<void> _initializeData() async {
    await calculateAverageRatings(allSites);
    setState(() {
      // Actualiza el estado si es necesario
    });
  }

  Future<void> fetchAndRecalculateAverageRating(Subsystem subsystem, University university) async {
    // Ajustar la colección y documento basado en el `nombre` de cada `Subsystem` y el ID de la universidad
    final snapshot = await FirebaseFirestore.instance
        .collection('universities') // Colección de universidades
        .doc(university.id.toString()) // Usar el ID de la universidad desde el objeto
        .collection('subsystems') // Colección de subsistemas dentro de la universidad
        .doc(subsystem.id.toString()) // ID del subsistema
        .collection('userRatings') // Colección de calificaciones de usuarios
        .get();

    final newRatings = snapshot.docs.map((doc) => doc['rating'] as double).toList();
    
    if (newRatings.isNotEmpty) {
      subsystem.ratings.clear();
      subsystem.ratings.addAll(newRatings);
      subsystem.averageRating = subsystem.ratings.reduce((a, b) => a + b) / subsystem.ratings.length;
    } else {
      subsystem.averageRating = 0; // Establecer un promedio de 0 si no hay calificaciones
    }
  }

  void _sortSitesByName() {
    setState(() {
      filteredSites.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  // Reordenar sitios para que los pineados vayan al inicio
  void _reorderPinnedSites() {
    setState(() {
      filteredSites.sort((a, b) {
        if (pinnedSites.contains(a) && !pinnedSites.contains(b)) return -1;
        if (!pinnedSites.contains(a) && pinnedSites.contains(b)) return 1;
        return a.name.compareTo(b.name);
      });
    });
  }

  // Actualizar la lista de sitios pinneados y guardar en SharedPreferences
  void _pinSite(Subsystem site) {
    setState(() {
      if (pinnedSites.contains(site)) {
        pinnedSites.remove(site);
      } else {
        pinnedSites.add(site);
      }
      _reorderPinnedSites(); // Restaurar el orden con los sitios pinneados
      _savePinnedSites(); // Guardar los cambios en SharedPreferences
    });
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            // Al hacer clic en el acrónimo, navegar de regreso a HomeUniversities
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeUniversities()),
            );
          },
          child: Text(
            widget.university.acronyms,
            style: GoogleFonts.roboto(fontSize: 25),
          ),
        ),
        actions: [
          // BOTÓN DE CALENDARIO
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {

              Navigator.push(
                context, 
                MaterialPageRoute(
                  builder: (_) => CalendarPage()
                )
              );
            },
          ),
          SizedBox(width: 6),
          


          // BOTÓN DE RANKING
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () async {
              await Future.wait(allSites.map((site) => fetchAndRecalculateAverageRating(site, widget.university)));
              setState(() {});
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RankingsPage(sites: allSites),
                ),
              );
            },
          ),
          SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: ValueListenableBuilder(
              valueListenable: _isTextPresent,
              builder: (context, isTextPresent, child) {
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    border: Border.all(color: Colors.grey.shade200),
                    color: Colors.grey.shade200,
                  ),
                  child: TextField(
                    controller: textEditingController,
                    onChanged: (text) {
                      setState(() {
                        filteredSites = allSites.where((site) {
                          final lowerCaseQuery = text.toLowerCase();
                          final matchesName = site.name.toLowerCase().contains(lowerCaseQuery);
                          final matchesProcedures = site.procedures.any((procedure) => procedure.toLowerCase().contains(lowerCaseQuery));
                          return matchesName || matchesProcedures;
                        }).toList();

                        _reorderPinnedSites(); // Reordenar para que los sitios fijados vayan al inicio
                      });
                    },

                    decoration: InputDecoration(
                      hintText: '   Buscar sitios o trámites...',
                      hintStyle: GoogleFonts.openSans(
                        fontSize: 17,
                        color: Colors.grey,
                      ),
                      prefixIcon: Icon(Icons.search), // Añadir ícono de lupa
                      suffixIcon: isTextPresent
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                filteredSites = allSites; // Resetear la lista a todos los sitios
                                _sortSitesByName(); // Ordenar por nombre
                                _reorderPinnedSites(); // Reordenar para que los sitios fijados estén arriba
                              });
                              textEditingController.clear(); // Limpiar el texto del cuadro de búsqueda
                            },
                          )
                        : null,
                      border: InputBorder.none, // Sin bordes adicionales
                      contentPadding: EdgeInsets.symmetric(vertical: 15), // Centrar verticalmente
                    ),
                    style: TextStyle(height: 1.5), // Centrar el texto
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshSites,
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
                    final site = filteredSites[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      clipBehavior: Clip.antiAlias, // Contenido se recorte en los bordes redondeados
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SiteDetailPage(site: site, university: widget.university,),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: site.image.startsWith('http')
                                    ? CachedNetworkImageProvider(site.image) // Usa CachedNetworkImageProvider para URLs
                                    : AssetImage(site.image), // Usa AssetImage para imágenes locales

                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),

                            // DEGRADE
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, Colors.black87],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),

                            // ICONO PIN DENTRO DE UN CÍRCULO
                            Positioned(
                              top: 20,
                              right: 20,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black.withOpacity(0.5), // Fondo oscuro para visibilidad
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    pinnedSites.contains(site)
                                        ? Icons.push_pin
                                        : Icons.push_pin_outlined,
                                    color: pinnedSites.contains(site) ? Color.fromARGB(255, 247, 173, 1) : Colors.white,
                                  ),
                                  onPressed: () => _pinSite(site),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 9,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  site.name,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
