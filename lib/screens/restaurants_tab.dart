import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/user.dart';
import '../models/restaurant.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';
import 'restaurant_detail_screen.dart';

class RestaurantsTab extends StatefulWidget {
  final User user;

  const RestaurantsTab({super.key, required this.user});

  @override
  State<RestaurantsTab> createState() => _RestaurantsTabState();
}

class _RestaurantsTabState extends State<RestaurantsTab> {
  final ApiService _apiService = ApiService();
  List<Restaurant> _restaurants = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Set<int> _favoriteIds = {};

  @override
  void initState() {
    super.initState();
    _apiService.setToken(widget.user.token);
    _loadRestaurants();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoritesService.getFavorites();
    setState(() {
      _favoriteIds = favorites.map((r) => r.id).toSet();
    });
  }

  Future<void> _toggleFavorite(Restaurant restaurant) async {
    if (_favoriteIds.contains(restaurant.id)) {
      await FavoritesService.removeFavorite(restaurant.id);
      setState(() {
        _favoriteIds.remove(restaurant.id);
      });
    } else {
      await FavoritesService.addFavorite(restaurant);
      setState(() {
        _favoriteIds.add(restaurant.id);
      });
    }
  }

  Future<void> _loadRestaurants() async {
    try {
      final restaurants = await _apiService.getRestaurants();
      setState(() {
        _restaurants = restaurants;
        _isLoading = false;
      });
      // Actualizar favoritos después de cargar restaurantes
      await _loadFavorites();
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los restaurantes';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                });
                _loadRestaurants();
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_restaurants.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No hay restaurantes disponibles',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadRestaurants,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = _restaurants[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RestaurantDetailScreen(
                      restaurant: restaurant,
                      user: widget.user,
                    ),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: restaurant.image.isNotEmpty
                              ? restaurant.image
                              : 'https://via.placeholder.com/400x200?text=No+Image',
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          httpHeaders: const {'User-Agent': 'FoodApp/1.0'},
                          placeholder: (context, url) => Container(
                            height: 200,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFF6B6B),
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) {
                            print('Error loading image: $error');
                            return Container(
                              height: 200,
                              color: Colors.grey[200],
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.restaurant,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Imagen no disponible',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => _toggleFavorite(restaurant),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _favoriteIds.contains(restaurant.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: _favoriteIds.contains(restaurant.id)
                                  ? Colors.red
                                  : Colors.grey,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            RatingBarIndicator(
                              rating: restaurant.rating,
                              itemBuilder: (context, index) =>
                                  const Icon(Icons.star, color: Colors.amber),
                              itemCount: 5,
                              itemSize: 20.0,
                              direction: Axis.horizontal,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${restaurant.rating.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          restaurant.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
