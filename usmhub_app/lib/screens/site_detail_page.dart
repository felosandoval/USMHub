import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:usmhub_app/models/university.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/subsystem.dart';
import '../services/auth_service.dart';

class SiteDetailPage extends StatefulWidget {
  final Subsystem site;
  final University university;

  SiteDetailPage({required this.site, required this.university});

  @override
  _SiteDetailPageState createState() => _SiteDetailPageState();
}

class _SiteDetailPageState extends State<SiteDetailPage> {
  final AuthService _authService = AuthService(); // Instancia de AuthService
  double? _userRating;
  int _totalReviews = 0;
  final user = FirebaseAuth.instance.currentUser;
   bool isRatingLoaded = false; // Variable para controlar si la calificación ha sido cargada

  @override
  void initState() {
    super.initState();
    _checkUserRating();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        setState(() {
           isRatingLoaded = false; // Restablecer el estado de carga de la calificación
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
              .collection('universities')
              .doc(widget.university.id.toString())
              .collection('subsystems')
              .doc(widget.site.id.toString())
              .collection('userRatings')
              .doc(user.email)
              .get();
        });
        if (doc.exists) {
          setState(() {
            _userRating = doc['rating'];
          });
        } else {
          setState(() {
            _userRating = null;
          });
        }
        isRatingLoaded = true; // Marcar que la calificación ha sido cargada
        _calculateAverageRating();
      } catch (e) {
        print('Error al obtener el rating del usuario: $e');
      }
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
        .collection('universities')
        .doc(widget.university.id.toString())
        .collection('subsystems')
        .doc(widget.site.id.toString())
        .collection('userRatings')
        .get();
    return snapshot.docs.length;
  }

  void _calculateAverageRating() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('universities')
        .doc(widget.university.id.toString())
        .collection('subsystems')
        .doc(widget.site.id.toString())
        .collection('userRatings')
        .get();
    if (snapshot.docs.isNotEmpty) {
      final totalRatings = snapshot.docs.map((doc) => doc['rating'] as double).reduce((a, b) => a + b);
      if (mounted) {
        setState(() {
          widget.site.averageRating = totalRatings / snapshot.docs.length;
          _totalReviews = snapshot.docs.length;
        });
      }
    }
  }

  void _submitRating(double rating) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection('universities')
          .doc(widget.university.id.toString())
          .collection('subsystems')
          .doc(widget.site.id.toString())
          .collection('userRatings')
          .doc(currentUser.email)
          .set({'rating': rating});
      _calculateAverageRating();
    }
  }

  @override


  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Información del sitio",
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título con imagen de fondo (título en parte inferior izquierda)
            Stack(
              children: [
                // Imagen de fondo
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: CachedNetworkImageProvider(widget.site.image), // Usando site.image
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                ),
                // Sombreado para mejorar la legibilidad del texto
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
                // Texto del título con borde negro
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Stack(
                    children: [
                      // Texto con borde negro (stroke)
                      // Texto blanco relleno
                      Text(
                        widget.site.name,
                        style: GoogleFonts.roboto(
                          fontSize: 30, // Aumentar el tamaño de la fuente
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Calificación
            if (widget.site.averageRating > 0)
              Row(
                children: [
                  Icon(Icons.star, color: Colors.amber, size: 24),
                  SizedBox(width: 5),
                  Text(
                    widget.site.averageRating.toStringAsFixed(1),
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 5),
                  FutureBuilder<int>(
                    future: _getTotalReviews(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Text(
                          '($_totalReviews reseñas)',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        );
                      } else {
                        return Text(
                          '(${snapshot.data ?? _totalReviews} reseñas)',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        );
                      }
                    },
                  ),
                ],
              ),
            Divider(height: 30, thickness: 1),
            // Descripción
            Text(
              widget.site.details,
              style: GoogleFonts.roboto(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            // Trámites disponibles
            Text(
              'Trámites disponibles:',
              style: GoogleFonts.roboto(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.site.procedures
                  .map((procedure) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline, color: Colors.green),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                procedure,
                                style: TextStyle(fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
            SizedBox(height: 30),
            // Botón IR AL SITIO (agrandado)
            Center(
              child: SizedBox(
                width: 220, // Hacer que el botón ocupe todo el ancho posible
                child: ElevatedButton(
                  onPressed: () => _launchURL(widget.site.url),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10), // Aumentar el padding vertical
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.link), // Icono de internet a la izquierda del texto
                        SizedBox(width: 8), // Espacio entre el icono y el texto
                        Text(
                          'Ir al Sitio',
                          style: TextStyle(fontSize: 18), // Aumentar el tamaño de la letra
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            // Calificar este sitio (centrado)
            Center(
              child: Column(
                children: [
                  Text(
                    'Calificar este sitio:',
                    style: GoogleFonts.roboto(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  if (user != null) ...[
                    if (isRatingLoaded)
                      Column(
                        children: [
                          RatingBar.builder(
                            initialRating: _userRating ?? 0.0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            itemCount: 5,
                            itemBuilder: (context, _) =>
                                Icon(Icons.star, color: Colors.amber),
                            onRatingUpdate: (rating) {
                              setState(() {
                                _userRating = rating;
                              });
                              _submitRating(rating);
                            },
                          ),
                          SizedBox(height: 10),
                          Text(
                            _userRating?.toStringAsFixed(1) ?? '0.0',
                            style:
                                TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await _authService.signOutWithGoogle();
                        setState(() {});
                        _checkUserRating();
                      },
                      child: Text('Cerrar sesión'),
                    ),
                  ] else ...[
                    ElevatedButton(
                      onPressed: () async {
                        await _authService.signInWithGoogle(context, () {
                          setState(() {
                            _userRating = 0.0;
                            _checkUserRating();
                          });
                        });
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/images/logo_google.png',
                            height: 24.0,
                            width: 24.0,
                          ),
                          SizedBox(width: 10),
                          Text('Continuar con Google'),
                        ],
                      ),
                    ),
                  ],
                ],
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