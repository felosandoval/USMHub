import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<Subsystem> allSites = [];
  List<Subsystem> filteredSites = [];
  ValueNotifier<bool> _isTextPresent = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    _refreshSites(); // Initial data load
    textEditingController.addListener(() {
      _isTextPresent.value = textEditingController.text.isNotEmpty;
    });
  }

  Future<void> _refreshSites() async {
    final snapshot = await FirebaseFirestore.instance.collection('subsystems').get();
    setState(() {
      allSites = snapshot.docs.map((doc) => Subsystem.fromJson(doc.data() as Map<String, dynamic>)).toList();
      filteredSites = allSites;
      _sortSitesByName();
      _initializeData();
    });
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
  void dispose() {
    textEditingController.dispose();
    super.dispose();
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
          // BOTÓN DE CALENDARIO
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => CalendarPage()));
            },
          ),
          // BOTÓN DE RANKING
          IconButton(
            icon: Icon(Icons.bar_chart),
            onPressed: () async {
              await Future.wait(allSites.map((site) => site.fetchAndRecalculateAverageRating()));
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
                          final matchesProcedures = site.procedures
                              .any((procedure) => procedure.toLowerCase().contains(lowerCaseQuery));
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
                      prefixIcon: Icon(Icons.search), // Añadir ícono de lupa
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
                      border: InputBorder.none, // Sin bordes adicionales para el TextField
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
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      clipBehavior: Clip.antiAlias, // Esto permite que el contenido se recorte en los bordes redondeados
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SiteDetailPage(site: filteredSites[index]),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: filteredSites[index].image.startsWith('http')
                                    ? NetworkImage(filteredSites[index].image)
                                    : AssetImage(filteredSites[index].image),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, Colors.black87],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 0,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  filteredSites[index].name,
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
