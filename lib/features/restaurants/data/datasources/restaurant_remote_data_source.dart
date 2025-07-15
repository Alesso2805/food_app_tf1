import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/restaurant_model.dart';
import '../models/comment_model.dart';

abstract class RestaurantRemoteDataSource {
  Future<List<RestaurantModel>> getRestaurants();
  Future<RestaurantModel> getRestaurantById(int id);
  Future<List<CommentModel>> getCommentsByRestaurant(int restaurantId);
  Future<void> addComment(int restaurantId, String comment, double rating);
  void setToken(String token);
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final http.Client client;
  static const String baseUrl =
      'https://foodapp-eqayckejbjg3eqgn.eastus-01.azurewebsites.net';
  String? _token;

  RestaurantRemoteDataSourceImpl({required this.client});

  @override
  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'User-Agent': 'FoodApp/1.0',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  @override
  Future<List<RestaurantModel>> getRestaurants() async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/restaurants'),
        headers: _headers,
      );

      print('Restaurants response status: ${response.statusCode}');
      print('Restaurants response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> restaurantsData = jsonData['data'];
          return restaurantsData
              .map((json) => RestaurantModel.fromJson(json))
              .toList();
        } else {
          throw Exception(
            'Failed to load restaurants: ${jsonData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Get restaurants error: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<RestaurantModel> getRestaurantById(int id) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/restaurants/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          return RestaurantModel.fromJson(jsonData['data']);
        } else {
          throw Exception(
            'Failed to load restaurant: ${jsonData['message'] ?? 'Unknown error'}',
          );
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Get restaurant error: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<List<CommentModel>> getCommentsByRestaurant(int restaurantId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/restaurants/$restaurantId/comments'),
        headers: _headers,
      );

      print('Comments response status: ${response.statusCode}');
      print('Comments response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = jsonDecode(response.body);

        if (jsonData['success'] == true && jsonData['data'] != null) {
          final List<dynamic> commentsData = jsonData['data'];
          return commentsData
              .map((json) => CommentModel.fromJson(json))
              .toList();
        } else {
          return [];
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Get comments error: $e');
      throw Exception('Network error: $e');
    }
  }

  @override
  Future<void> addComment(
    int restaurantId,
    String comment,
    double rating,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/restaurants/$restaurantId/comments'),
        headers: _headers,
        body: jsonEncode({'text': comment, 'rating': rating}),
      );

      print('Add comment response status: ${response.statusCode}');
      print('Add comment response body: ${response.body}');

      if (response.statusCode != 201) {
        throw Exception('Failed to add comment: ${response.statusCode}');
      }
    } catch (e) {
      print('Add comment error: $e');
      throw Exception('Network error: $e');
    }
  }
}
