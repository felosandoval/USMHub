class Subsystem {
  final int id;
  final String name;
  final String url;
  final String details;
  final List<String> procedures;
  final List<double> ratings;
  final String image; // Añadir este campo
  double _averageRating;

  Subsystem({
    required this.id,
    required this.name,
    required this.url,
    required this.details,
    required this.procedures,
    required this.ratings,
    required this.image, // Añadir este campo al constructor
    double? averageRating,
  }): _averageRating = averageRating ?? 0.0;

  double get averageRating => _averageRating;
  
  set averageRating(double value) {
    _averageRating = value;
  }

  factory Subsystem.fromJson(Map<String, dynamic> json) {
    return Subsystem(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      details: json['details'],
      procedures: List<String>.from(json['procedures']),
      ratings: List<double>.from(json['ratings'].map((x) => x.toDouble())),
      image: json['image'],
    );
  }
}