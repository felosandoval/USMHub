import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/subsystem.dart'; // Asegúrate de que la ruta a Subsystem sea correcta

Future<void> _calculateAverageRating(Subsystem site) async {
  final snapshot = await FirebaseFirestore.instance
      .collection('subsystems')
      .doc(site.id.toString())
      .collection('userRatings')
      .get();
  if (snapshot.docs.isNotEmpty) {
    final totalRatings = snapshot.docs.map((doc) => doc['rating'] as double).reduce((a, b) => a + b);
    site.averageRating = totalRatings / snapshot.docs.length; // Asigna el promedio de Valoración al sitio
  }
}

Future<void> calculateAverageRatings(List<Subsystem> allSites) async {
  for (var site in allSites) {
    await _calculateAverageRating(site);
  }
}