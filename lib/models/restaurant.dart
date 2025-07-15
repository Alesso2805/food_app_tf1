class Restaurant {
  final int id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String website;
  final String image;
  final double rating;
  final double latitude;
  final double longitude;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.website,
    required this.image,
    required this.rating,
    required this.latitude,
    required this.longitude,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? 0,
      name: json['title'] ?? json['name'] ?? '', // Soportar ambos campos
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'] ?? '',
      image: json['poster'] ?? json['image'] ?? '', // Soportar ambos campos
      rating: (json['rating'] ?? 0.0).toDouble(),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': name,
      'description': description,
      'address': address,
      'phone': phone,
      'website': website,
      'poster': image,
      'rating': rating,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
