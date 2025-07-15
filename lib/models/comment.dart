class Comment {
  final int id;
  final String userName;
  final String userEmail;
  final String content;
  final double rating;
  final DateTime createdAt;
  final int restaurantId;

  Comment({
    required this.id,
    required this.userName,
    required this.userEmail,
    required this.content,
    required this.rating,
    required this.createdAt,
    required this.restaurantId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    // Extraer información del usuario si viene en un objeto user
    final user = json['user'] as Map<String, dynamic>?;

    return Comment(
      id: json['id'] ?? 0,
      userName: user != null
          ? '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}'.trim()
          : json['userName'] ?? '',
      userEmail: user != null ? user['email'] ?? '' : json['userEmail'] ?? '',
      content: json['comment'] ?? json['content'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      restaurantId: json['restaurantId'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userName': userName,
      'userEmail': userEmail,
      'comment': content, // Cambiado de 'content' a 'comment'
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'restaurantId': restaurantId,
    };
  }
}
