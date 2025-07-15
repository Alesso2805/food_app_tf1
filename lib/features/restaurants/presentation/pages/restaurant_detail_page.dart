import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../domain/entities/restaurant.dart';
import '../bloc/restaurant_bloc.dart';

class RestaurantDetailPage extends StatefulWidget {
  final Restaurant restaurant;
  final User user;

  const RestaurantDetailPage({
    super.key,
    required this.restaurant,
    required this.user,
  });

  @override
  State<RestaurantDetailPage> createState() => _RestaurantDetailPageState();
}

class _RestaurantDetailPageState extends State<RestaurantDetailPage> {
  final _commentController = TextEditingController();
  double _rating = 0.0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<RestaurantBloc>()),
        BlocProvider(create: (context) => sl<FavoritesBloc>()),
      ],
      child: BlocListener<RestaurantBloc, RestaurantState>(
        listener: (context, state) {
          if (state is CommentAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Comentario agregado exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            _commentController.clear();
            _rating = 0.0;
            // Reload comments
            context.read<RestaurantBloc>().add(
              GetCommentsEvent(widget.restaurant.id),
            );
          } else if (state is RestaurantError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              widget.restaurant.name,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFFF6B6B),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              BlocBuilder<FavoritesBloc, FavoritesState>(
                builder: (context, state) {
                  context.read<FavoritesBloc>().add(GetFavoritesEvent());

                  bool isFavorite = false;
                  if (state is FavoritesLoaded) {
                    isFavorite = state.favorites.any(
                      (fav) => fav.id == widget.restaurant.id,
                    );
                  }

                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      context.read<FavoritesBloc>().add(
                        ToggleFavoriteEvent(widget.restaurant),
                      );
                    },
                  );
                },
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
                      : 'https://via.placeholder.com/400x200?text=No+Image',
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  httpHeaders: const {'User-Agent': 'FoodApp/1.0'},
                  placeholder: (context, url) => Container(
                    height: 250,
                    color: Colors.grey[200],
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) {
                    return Container(
                      height: 250,
                      color: Colors.grey[200],
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            'Imagen no disponible',
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // Restaurant Info
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
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Contact Info
                      if (widget.restaurant.phone.isNotEmpty)
                        _buildContactItem(
                          Icons.phone,
                          'Teléfono',
                          widget.restaurant.phone,
                          () => _launchUrl('tel:${widget.restaurant.phone}'),
                        ),
                      if (widget.restaurant.address.isNotEmpty)
                        _buildContactItem(
                          Icons.location_on,
                          'Dirección',
                          widget.restaurant.address,
                          () => _launchMaps(),
                        ),
                      if (widget.restaurant.website.isNotEmpty)
                        _buildContactItem(
                          Icons.web,
                          'Sitio web',
                          widget.restaurant.website,
                          () => _launchUrl(widget.restaurant.website),
                        ),

                      const SizedBox(height: 24),
                      const Divider(),

                      // Comments Section
                      const Text(
                        'Comentarios',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Add Comment Form
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Agregar comentario',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              RatingBar.builder(
                                initialRating: _rating,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: true,
                                itemCount: 5,
                                itemSize: 24,
                                itemPadding: const EdgeInsets.symmetric(
                                  horizontal: 4.0,
                                ),
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
                              BlocBuilder<RestaurantBloc, RestaurantState>(
                                builder: (context, state) {
                                  return ElevatedButton(
                                    onPressed: state is RestaurantLoading
                                        ? null
                                        : _submitComment,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFFF6B6B),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: state is RestaurantLoading
                                        ? const SizedBox(
                                            height: 16,
                                            width: 16,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text('Enviar comentario'),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Comments List
                      BlocBuilder<RestaurantBloc, RestaurantState>(
                        builder: (context, state) {
                          if (state is RestaurantLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFFF6B6B),
                              ),
                            );
                          }

                          if (state is CommentsLoaded) {
                            if (state.comments.isEmpty) {
                              return const Center(
                                child: Text(
                                  'No hay comentarios aún',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: state.comments.length,
                              itemBuilder: (context, index) {
                                final comment = state.comments[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFFFF6B6B),
                                      child: Text(
                                        comment.username.isNotEmpty
                                            ? comment.username[0].toUpperCase()
                                            : 'U',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      comment.username,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
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
                                        const SizedBox(height: 4),
                                        Text(comment.text),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }

                          // Load comments when page loads
                          context.read<RestaurantBloc>().add(
                            GetCommentsEvent(widget.restaurant.id),
                          );

                          return const SizedBox();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem(
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFFF6B6B)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _submitComment() {
    if (_commentController.text.isNotEmpty && _rating > 0) {
      context.read<RestaurantBloc>().add(
        AddCommentEvent(
          restaurantId: widget.restaurant.id,
          comment: _commentController.text,
          rating: _rating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa un comentario y calificación'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchMaps() async {
    final String query = Uri.encodeComponent(widget.restaurant.address);
    final String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$query';

    await _launchUrl(googleUrl);
  }
}
