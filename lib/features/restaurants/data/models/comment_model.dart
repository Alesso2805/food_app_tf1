import '../../domain/entities/comment.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.username,
    required super.text,
    required super.rating,
    required super.restaurantId,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      text: json['text'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      restaurantId: json['restaurantId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'text': text,
      'rating': rating,
      'restaurantId': restaurantId,
    };
  }
}
