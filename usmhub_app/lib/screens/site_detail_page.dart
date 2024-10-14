import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/subsystem.dart'; // Suponiendo que hayas movido `Subsystem` a un archivo separado llamado subsystem.dart
import '../services/auth_service.dart';

class SiteDetailPage extends StatefulWidget {
  final Subsystem site;

  SiteDetailPage({required this.site});

  @override
  _SiteDetailPageState createState() => _SiteDetailPageState();
}

class _SiteDetailPageState extends State<SiteDetailPage> {
  final AuthService _authService = AuthService(); // Instancia de AuthService
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