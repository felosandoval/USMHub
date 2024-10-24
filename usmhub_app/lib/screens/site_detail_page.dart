import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:usmhub_app/models/university.dart';

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
                if (widget.site.averageRating > 0)
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber, // Puedes cambiar el color si prefieres otro
                      ),
                      SizedBox(width: 5),
                      Text(
                        widget.site.averageRating.toStringAsFixed(1),
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 5),
                      FutureBuilder<int>(
                        future: _getTotalReviews(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
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
            Center(
              child: ElevatedButton(
                onPressed: () => _launchURL(widget.site.url),
                child: Text('IR AL SITIO'),
              ),
            ),
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
              // Mostrar las estrellas solo si la calificación ha sido cargada
              if (isRatingLoaded) ...[
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
              ],
              // Si no se ha cargado la calificación, no se muestra nada
              SizedBox(height: 20),
              // Botón de cerrar sesión...
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    await _authService.signOutWithGoogle();
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
                    await _authService.signInWithGoogle(context, () {
                      setState(() {
                        _userRating = 0.0; // Restablecer la calificación al iniciar sesión
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
                      SizedBox(width: 10), // Espacio entre el icono y el texto
                      Text('Continuar con Google'),
                    ],
                  ),
                ),
              ),
            ],
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