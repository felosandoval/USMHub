class Empresa {
  final int id;
  final String name;
  final String url;
  final String details;
  final List<String> procedures;
  final List<double> ratings;
  final String image;

  Empresa({
    required this.id,
    required this.name,
    required this.url,
    required this.details,
    required this.procedures,
    required this.ratings,
    required this.image,
  });

  factory Empresa.fromJson(Map<String, dynamic> json) {
    return Empresa(
      id: json['id'],
      name: json['name'],
      url: json['url'],
      details: json['details'],
      procedures: List<String>.from(json['procedures']),
      ratings: List<double>.from(json['ratings']),
      image: json['image'],
    );
  }
}
