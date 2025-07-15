import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../restaurants/domain/entities/restaurant.dart';
import '../../../restaurants/data/models/restaurant_model.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_local_data_source.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesLocalDataSource localDataSource;

  FavoritesRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Restaurant>>> getFavorites() async {
    try {
      final favorites = await localDataSource.getFavorites();
      return Right(favorites);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addFavorite(Restaurant restaurant) async {
    try {
      // Convert entity to model for data layer
      final restaurantModel = RestaurantModel(
        id: restaurant.id,
        name: restaurant.name,
        description: restaurant.description,
        image: restaurant.image,
        rating: restaurant.rating,
        phone: restaurant.phone,
        address: restaurant.address,
        website: restaurant.website,
        latitude: restaurant.latitude,
        longitude: restaurant.longitude,
      );
      await localDataSource.addFavorite(restaurantModel);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFavorite(int restaurantId) async {
    try {
      await localDataSource.removeFavorite(restaurantId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isFavorite(int restaurantId) async {
    try {
      final result = await localDataSource.isFavorite(restaurantId);
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearFavorites() async {
    try {
      await localDataSource.clearFavorites();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
