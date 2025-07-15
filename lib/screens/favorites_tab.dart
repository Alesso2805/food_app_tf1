import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/user.dart';
import '../models/restaurant.dart';
import '../services/favorites_service.dart';
import 'restaurant_detail_screen.dart';

class FavoritesTab extends StatefulWidget {
  final User user;

  const FavoritesTab({super.key, required this.user});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab> {
  List<Restaurant> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await FavoritesService.getFavorites();
      print('Loaded ${favorites.length} favorites');

      for (var restaurant in favorites) {
        print('Favorite: ${restaurant.name}, image: ${restaurant.image}');
      }

      setState(() {
        _favorites = favorites;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() {
        _favorites = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(Restaurant restaurant) async {
    await FavoritesService.removeFavorite(restaurant.id);
    _loadFavorites();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${restaurant.name} eliminado de favoritos'),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
      );
    }

    if (_favorites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No tienes restaurantes favoritos',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Marca algunos restaurantes como favoritos para verlos aquí',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _favorites.length,
        itemBuilder: (context, index) {
          final restaurant = _favorites[index];
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
                ).then((_) => _loadFavorites());
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: restaurant.image.isNotEmpty
                            ? restaurant.image
                            : 'https://via.placeholder.com/60x60?text=No+Image',
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                        httpHeaders: const {'User-Agent': 'FoodApp/1.0'},
                        placeholder: (context, url) => Container(
                          height: 60,
                          width: 60,
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFFF6B6B),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          print('Error loading favorite image: $error');
                          print('URL: $url');
                          return Container(
                            height: 60,
                            width: 60,
                            color: Colors.grey[200],
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.restaurant,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                                Text(
                                  'Sin img',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            restaurant.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            restaurant.address,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Color(0xFFFF6B6B),
                      ),
                      onPressed: () => _removeFavorite(restaurant),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
