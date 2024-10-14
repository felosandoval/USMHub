import 'package:cloud_firestore/cloud_firestore.dart';

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