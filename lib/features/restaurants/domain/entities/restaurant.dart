import 'package:equatable/equatable.dart';

class Restaurant extends Equatable {
  final int id;
  final String name;
  final String description;
  final String image;
  final double rating;
  final String phone;
  final String address;
  final String website;
  final double latitude;
  final double longitude;

  const Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.rating,
    required this.phone,
    required this.address,
    required this.website,
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object> get props => [
    id,
    name,
    description,
    image,
    rating,
    phone,
    address,
    website,
    latitude,
    longitude,
  ];
}
