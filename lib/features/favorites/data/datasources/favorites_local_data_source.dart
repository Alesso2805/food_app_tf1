import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../restaurants/data/models/restaurant_model.dart';

abstract class FavoritesLocalDataSource {
  Future<List<RestaurantModel>> getFavorites();
  Future<void> addFavorite(RestaurantModel restaurant);
  Future<void> removeFavorite(int restaurantId);
  Future<bool> isFavorite(int restaurantId);
  Future<void> clearFavorites();
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String favoritesKey = 'favorites';

  FavoritesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<RestaurantModel>> getFavorites() async {
    try {
      final favoritesJson = sharedPreferences.getStringList(favoritesKey) ?? [];

      print('Loading favorites: ${favoritesJson.length} items');

      final favorites = favoritesJson
          .map((json) {
            try {
              final restaurantData = jsonDecode(json);
              final restaurant = RestaurantModel.fromJson(restaurantData);
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
          .cast<RestaurantModel>()
          .toList();

      return favorites;
    } catch (e) {
      print('Error loading favorites: $e');
      return [];
    }
  }

  @override
  Future<void> addFavorite(RestaurantModel restaurant) async {
    try {
      final favorites = await getFavorites();

      if (!favorites.any((fav) => fav.id == restaurant.id)) {
        favorites.add(restaurant);

        print(
          'Adding favorite: ${restaurant.name}, image: ${restaurant.image}',
        );

        final favoritesJson = favorites
            .map((restaurant) => jsonEncode(restaurant.toJson()))
            .toList();
        await sharedPreferences.setStringList(favoritesKey, favoritesJson);

        print('Favorite added successfully');
      } else {
        print('Restaurant already in favorites');
      }
    } catch (e) {
      print('Error adding favorite: $e');
      throw Exception('Failed to add favorite: $e');
    }
  }

  @override
  Future<void> removeFavorite(int restaurantId) async {
    try {
      final favorites = await getFavorites();

      favorites.removeWhere((restaurant) => restaurant.id == restaurantId);

      final favoritesJson = favorites
          .map((restaurant) => jsonEncode(restaurant.toJson()))
          .toList();
      await sharedPreferences.setStringList(favoritesKey, favoritesJson);

      print('Favorite removed successfully');
    } catch (e) {
      print('Error removing favorite: $e');
      throw Exception('Failed to remove favorite: $e');
    }
  }

  @override
  Future<bool> isFavorite(int restaurantId) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((restaurant) => restaurant.id == restaurantId);
    } catch (e) {
      print('Error checking favorite: $e');
      return false;
    }
  }

  @override
  Future<void> clearFavorites() async {
    try {
      await sharedPreferences.remove(favoritesKey);
      print('Favorites cleared');
    } catch (e) {
      print('Error clearing favorites: $e');
      throw Exception('Failed to clear favorites: $e');
    }
  }
}
