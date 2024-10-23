class University {
  final int id;
  final String name;
  final String acronyms;
  final String city;
  final String country;
  final String image;

  University({
    required this.id,
    required this.name,
    required this.acronyms,
    required this.city,
    required this.country,
    required this.image,
  });

  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      id: json['id'],
      name: json['name'],
      acronyms: json['acronyms'],
      city: json['city'],
      country: json['country'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'acronyms': acronyms,
      'city': city,
      'country': country,
      'image': image,
    };
  }
}