import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/user.dart';
import '../models/restaurant.dart';
import '../models/comment.dart';
import '../services/api_service.dart';
import '../services/favorites_service.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;
  final User user;

  const RestaurantDetailScreen({
    super.key,
    required this.restaurant,
    required this.user,
  });

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  final ApiService _apiService = ApiService();
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _isAddingComment = false;

  final _commentController = TextEditingController();
  double _rating = 5.0;

  @override
  void initState() {
    super.initState();
    _apiService.setToken(widget.user.token);
    _loadData();
  }

  // Método para refrescar cuando se vuelve a la pantalla
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recargar comentarios cuando se vuelve a la pantalla
    _loadComments();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadComments(), _checkFavoriteStatus()]);
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _apiService.getComments(widget.restaurant.id);
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkFavoriteStatus() async {
    final isFavorite = await FavoritesService.isFavorite(widget.restaurant.id);
    setState(() {
      _isFavorite = isFavorite;
    });
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await FavoritesService.removeFavorite(widget.restaurant.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.restaurant.name} eliminado de favoritos'),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    } else {
      await FavoritesService.addFavorite(widget.restaurant);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.restaurant.name} agregado a favoritos'),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    }
    _checkFavoriteStatus();
  }

  Future<void> _addComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isAddingComment = true;
    });

    try {
      final newComment = await _apiService.addComment(
        widget.restaurant.id,
        _commentController.text.trim(),
        _rating,
      );

      if (newComment != null) {
        _commentController.clear();
        _rating = 5.0;

        // Agregar el comentario inmediatamente a la lista
        setState(() {
          _comments.insert(0, newComment);
        });

        // También recargar desde el servidor para asegurar consistencia
        await _loadComments();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Comentario agregado exitosamente'),
              backgroundColor: Color(0xFFFF6B6B),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al agregar comentario'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error in _addComment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al agregar comentario'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isAddingComment = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No hay URL disponible'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Limpiar la URL y agregar protocolo si es necesario
    String cleanUrl = url.trim();
    if (!cleanUrl.startsWith('http://') && !cleanUrl.startsWith('https://')) {
      cleanUrl = 'https://$cleanUrl';
    }

    try {
      final Uri uri = Uri.parse(cleanUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se puede abrir el enlace'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error launching URL: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al abrir el enlace'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.restaurant.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFFF6B6B),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Image
            CachedNetworkImage(
              imageUrl: widget.restaurant.image.isNotEmpty
                  ? widget.restaurant.image
                  : 'https://via.placeholder.com/400x250?text=No+Image',
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              httpHeaders: const {'User-Agent': 'FoodApp/1.0'},
              placeholder: (context, url) => Container(
                height: 250,
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFFFF6B6B)),
                ),
              ),
              errorWidget: (context, url, error) {
                print('Error loading restaurant image: $error');
                return Container(
                  height: 250,
                  color: Colors.grey[200],
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.restaurant, size: 64, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'Imagen no disponible',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Restaurant Details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.restaurant.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: widget.restaurant.rating,
                        itemBuilder: (context, index) =>
                            const Icon(Icons.star, color: Colors.amber),
                        itemCount: 5,
                        itemSize: 24.0,
                        direction: Axis.horizontal,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.restaurant.rating.toStringAsFixed(1)}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.restaurant.description,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // Contact Information
                  _buildInfoRow(
                    Icons.location_on,
                    'Dirección',
                    widget.restaurant.address,
                  ),
                  _buildInfoRow(
                    Icons.phone,
                    'Teléfono',
                    widget.restaurant.phone,
                  ),
                  _buildInfoRow(
                    Icons.web,
                    'Sitio web',
                    widget.restaurant.website,
                    isUrl: true,
                  ),

                  const SizedBox(height: 24),

                  // Add Comment Section
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Agregar Comentario',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('Calificación:'),
                          const SizedBox(height: 8),
                          RatingBar.builder(
                            initialRating: _rating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: false,
                            itemCount: 5,
                            itemSize: 30,
                            itemBuilder: (context, _) =>
                                const Icon(Icons.star, color: Colors.amber),
                            onRatingUpdate: (rating) {
                              setState(() {
                                _rating = rating;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: _commentController,
                            decoration: const InputDecoration(
                              hintText: 'Escribe tu comentario...',
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isAddingComment ? null : _addComment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF6B6B),
                                foregroundColor: Colors.white,
                              ),
                              child: _isAddingComment
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text('Agregar Comentario'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Comments Section
                  const Text(
                    'Comentarios',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  if (_isLoading)
                    const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B6B),
                      ),
                    )
                  else if (_comments.isEmpty)
                    const Center(
                      child: Text(
                        'No hay comentarios aún',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        final comment = _comments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        comment.userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    RatingBarIndicator(
                                      rating: comment.rating,
                                      itemBuilder: (context, index) =>
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                          ),
                                      itemCount: 5,
                                      itemSize: 16.0,
                                      direction: Axis.horizontal,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  comment.content,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatDate(comment.createdAt),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isUrl = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFF6B6B), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: isUrl ? () => _launchUrl(value) : null,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: isUrl ? Colors.blue : Colors.grey[600],
                      decoration: isUrl ? TextDecoration.underline : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
