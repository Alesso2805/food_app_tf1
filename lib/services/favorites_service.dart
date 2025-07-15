import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/restaurant.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorites';

  static Future<List<Restaurant>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      print('Loading favorites: ${favoritesJson.length} items');

      final favorites = favoritesJson
          .map((json) {
            try {
              final restaurant = Restaurant.fromJson(jsonDecode(json));
              print(
                'Loaded restaurant: ${restaurant.name}, image: ${restaurant.image}',
              );
              return restaurant;
            } catch (e) {
              print('Error parsing favorite restaurant: $e');
              return null;
            }
          })
          .where((restaurant) => restaurant != null)
          .cast<Restaurant>()
          .toList();

      return favorites;
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }

  static Future<void> addFavorite(Restaurant restaurant) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favorites = await getFavorites();

      // Check if restaurant is already in favorites
      if (!favorites.any((fav) => fav.id == restaurant.id)) {
        favorites.add(restaurant);

        print(
          'Adding favorite: ${restaurant.name}, image: ${restaurant.image}',
        );

        final favoritesJson = favorites
            .map((restaurant) => jsonEncode(restaurant.toJson()))
            .toList();
        await prefs.setStringList(_favoritesKey, favoritesJson);

        print('Favorite added successfully');
      } else {
        print('Restaurant already in favorites');
      }
    } catch (e) {
      print('Error adding favorite: $e');
    }
  }

  static Future<void> removeFavorite(int restaurantId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = await getFavorites();

    favorites.removeWhere((restaurant) => restaurant.id == restaurantId);
    final favoritesJson = favorites
        .map((restaurant) => jsonEncode(restaurant.toJson()))
        .toList();
    await prefs.setStringList(_favoritesKey, favoritesJson);
  }

  static Future<bool> isFavorite(int restaurantId) async {
    final favorites = await getFavorites();
    return favorites.any((restaurant) => restaurant.id == restaurantId);
  }

  static Future<void> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
      print('Favorites cleared');
    } catch (e) {
      print('Error clearing favorites: $e');
    }
  }
}
