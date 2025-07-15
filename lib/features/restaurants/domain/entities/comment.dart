import 'package:equatable/equatable.dart';

class Comment extends Equatable {
  final int id;
  final String username;
  final String text;
  final double rating;
  final int restaurantId;

  const Comment({
    required this.id,
    required this.username,
    required this.text,
    required this.rating,
    required this.restaurantId,
  });

  @override
  List<Object> get props => [id, username, text, rating, restaurantId];
}
