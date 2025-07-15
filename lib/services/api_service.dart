import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';
import '../models/comment.dart';
import '../models/user.dart';

class ApiService {
  static const String baseUrl =
      'https://foodapp-eqayckejbjg3eqgn.eastus-01.azurewebsites.net';

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<User?> login(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/users/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);
        setToken(user.token);
        return user;
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }

  Future<List<Restaurant>> getRestaurants() async {
    try {
      print('Fetching restaurants from: $baseUrl/api/restaurants');

      final response = await http
          .get(Uri.parse('$baseUrl/api/restaurants'), headers: _headers)
          .timeout(const Duration(seconds: 10));

      print('Get restaurants response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Number of restaurants received: ${data.length}');

        final restaurants = data
            .map((json) => Restaurant.fromJson(json))
            .toList();

        // Debug: mostrar información de las primeras imágenes
        for (int i = 0; i < restaurants.length && i < 3; i++) {
          print('Restaurant ${i + 1}: ${restaurants[i].name}');
          print('Image URL: ${restaurants[i].image}');
        }

        return restaurants;
      }
      return [];
    } catch (e) {
      print('Get restaurants error: $e');
      return [];
    }
  }

  Future<List<Comment>> getComments(int restaurantId) async {
    try {
      print('Fetching comments for restaurant: $restaurantId');

      final response = await http
          .get(
            Uri.parse('$baseUrl/api/comments/$restaurantId'),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 10));

      print('Get comments response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Number of comments received: ${data.length}');
        return data.map((json) => Comment.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Get comments error: $e');
      return [];
    }
  }

  Future<Comment?> addComment(
    int restaurantId,
    String content,
    double rating,
  ) async {
    try {
      print(
        'Adding comment: restaurantId=$restaurantId, content=$content, rating=$rating',
      );

      final requestBody = {
        'restaurantId': restaurantId,
        'comment': content,
        'rating': rating,
      };

      print('Request body: ${jsonEncode(requestBody)}');
      print('Headers: $_headers');

      final response = await http
          .post(
            Uri.parse('$baseUrl/api/comments'),
            headers: _headers,
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 10));

      print('Add comment response status: ${response.statusCode}');
      print('Add comment response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Comment added successfully');

        // Intentar parsear la respuesta como comentario
        try {
          final data = jsonDecode(response.body);
          return Comment.fromJson(data);
        } catch (e) {
          print('Error parsing comment response: $e');
          return null;
        }
      } else {
        print(
          'Failed to add comment: ${response.statusCode} - ${response.body}',
        );
        return null;
      }
    } catch (e) {
      print('Add comment error: $e');
      return null;
    }
  }
}
