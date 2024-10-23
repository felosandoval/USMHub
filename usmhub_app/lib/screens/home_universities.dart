import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';


import 'subsystems_page.dart';
import '../models/university.dart';

class HomeUniversities extends StatefulWidget {
  @override
  _HomeUniversitiesState createState() => _HomeUniversitiesState();
}

class _HomeUniversitiesState extends State<HomeUniversities> {
  TextEditingController textEditingController = TextEditingController();
  List<University> allUniversities = [];
  List<University> filteredUniversities = [];
  List<University> pinnedUniversities = []; // Lista de universidades fijadas
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

  // Inicializa SharedPreferences y recarga universidades fijadas
  Future<void> _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
    await _refreshUniversities(); // Espera a que se carguen las universidades
    _loadPinnedUniversities(); // Cargar las universidades fijadas aquí
  }

  // Refresca las universidades en base a los datos de Firebase
  Future<void> _refreshUniversities() async {
    final snapshot = await FirebaseFirestore.instance
    .collection('universities').get();
    setState(() {
      allUniversities = snapshot.docs.map((doc) => University.fromJson(doc.data())).toList();
      filteredUniversities = List.from(allUniversities); // Copiar la lista completa
      _loadPinnedUniversities(); // Restaurar las universidades fijadas desde SharedPreferences
      _sortUniversitiesByName();
      _reorderPinnedUniversities(); // Reordenar universidades fijadas
    });
  }

  Future<void> _saveSelectedUniversity(University university) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String universityJson = jsonEncode(university.toJson()); // Convierte a JSON
    await prefs.setString('selectedUniversity', universityJson); // Guarda como string
  }


  // Cargar universidades fijadas desde SharedPreferences
  void _loadPinnedUniversities() {
    final pinnedUniversityIds = prefs?.getStringList('pinnedUniversities') ?? [];
    setState(() {
      pinnedUniversities = allUniversities.where((university) {
        final universityId = university.id.toString(); // Convertir ID de la universidad a String
        return pinnedUniversityIds.contains(universityId);
      }).toList();
    });
  }

  // Guardar las universidades fijadas en SharedPreferences
  void _savePinnedUniversities() {
    final pinnedUniversityIds = pinnedUniversities.map((university) => university.id.toString()).toList(); // Convertir a String
    prefs?.setStringList('pinnedUniversities', pinnedUniversityIds);
  }

  void _sortUniversitiesByName() {
    setState(() {
      filteredUniversities.sort((a, b) => a.name.compareTo(b.name));
    });
  }

  // Reordenar universidades para que las fijadas vayan al inicio
  void _reorderPinnedUniversities() {
    setState(() {
      filteredUniversities.sort((a, b) {
        if (pinnedUniversities.contains(a) && !pinnedUniversities.contains(b)) return -1;
        if (!pinnedUniversities.contains(a) && pinnedUniversities.contains(b)) return 1;
        return a.name.compareTo(b.name);
      });
    });
  }

  // Actualizar la lista de universidades fijadas y guardar en SharedPreferences
  void _pinUniversity(University university) {
    setState(() {
      if (pinnedUniversities.contains(university)) {
        pinnedUniversities.remove(university);
      } else {
        pinnedUniversities.add(university);
      }
      _reorderPinnedUniversities(); // Restaurar el orden con las universidades fijadas
      _savePinnedUniversities(); // Guardar los cambios en SharedPreferences
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
          'UHub',
          style: GoogleFonts.roboto(fontSize: 25),
        ),
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
                        filteredUniversities = allUniversities.where((university) {
                          final lowerCaseQuery = text.toLowerCase();
                          final matchesName = university.name.toLowerCase().contains(lowerCaseQuery);
                          return matchesName; // Filtrar solo por nombre
                        }).toList();

                        _reorderPinnedUniversities(); // Reordenar para que las universidades fijadas vayan al inicio
                      });
                    },

                    decoration: InputDecoration(
                      hintText: '   Buscar instituciones ...',
                      hintStyle: GoogleFonts.openSans(
                        fontSize: 17,
                        color: const Color.fromARGB(162, 158, 158, 158),
                      ),
                      prefixIcon: Icon(Icons.search), // Añadir ícono de lupa
                      suffixIcon: isTextPresent
                        ? IconButton(
                            icon: Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                filteredUniversities = allUniversities; // Resetear la lista a todas las universidades
                                _sortUniversitiesByName(); // Ordenar por nombre
                                _reorderPinnedUniversities(); // Reordenar para que las universidades fijadas estén arriba
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
              onRefresh: _refreshUniversities,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: filteredUniversities.length,
                  itemBuilder: (context, index) {
                    final university = filteredUniversities[index];

                    _saveSelectedUniversity(university);
                    
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
                              builder: (_) => SubsystemsPage(university: university),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: university.image.startsWith('http')
                                    ? CachedNetworkImageProvider(university.image) // Usa CachedNetworkImageProvider para URLs
                                    : AssetImage(university.image), // Usa AssetImage para imágenes locales
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

                            // ICONO PIN DENTRO DEL CARD
                            Positioned(
                              right: 20,
                              top: 20,
                              child: GestureDetector(
                                onTap: () => _pinUniversity(university), // Llamar al método de fijar
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle, // Forma circular
                                    color: pinnedUniversities.contains(university) ? Colors.white : Colors.white, // Color de fondo
                                    border: Border.all(color: Colors.black, width: 0.5), // Borde negro
                                  ),
                                  padding: EdgeInsets.all(10), // Espaciado interno
                                  child: Icon(
                                    pinnedUniversities.contains(university) ? Icons.favorite : Icons.favorite_border,
                                    color: pinnedUniversities.contains(university) ? Colors.red : Colors.red, // Cambiar el color del ícono
                                    size: 25, // Tamaño del ícono
                                  ),
                                ),
                              ),
                            ),

                            // NOMBRE DE LA UNIVERSIDAD
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20, // Asegúrate de que ocupe el espacio de la tarjeta
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end, // Alinea hacia abajo
                                  crossAxisAlignment: CrossAxisAlignment.start, // Alinea a la izquierda
                                  children: [
                                    Container(
                                      constraints: BoxConstraints(maxWidth: double.infinity), // Limitar el ancho
                                      child: Text(
                                        university.name,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis, // Evitar que se salga de la tarjeta
                                        maxLines: 4, // Permitir hasta dos líneas
                                      ),
                                    ),
                                  ],
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
