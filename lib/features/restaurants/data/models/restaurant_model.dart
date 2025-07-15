import '../../domain/entities/restaurant.dart';

class RestaurantModel extends Restaurant {
  const RestaurantModel({
    required super.id,
    required super.name,
    required super.description,
    required super.image,
    required super.rating,
    required super.phone,
    required super.address,
    required super.website,
    required super.latitude,
    required super.longitude,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id: json['id'] ?? 0,
      name: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['poster'] ?? json['image'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      website: json['website'] ?? '',
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': name,
      'description': description,
      'poster': image,
      'rating': rating,
      'phone': phone,
      'address': address,
      'website': website,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
