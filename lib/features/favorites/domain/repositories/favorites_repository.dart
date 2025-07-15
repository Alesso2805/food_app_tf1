import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../restaurants/domain/entities/restaurant.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, List<Restaurant>>> getFavorites();
  Future<Either<Failure, void>> addFavorite(Restaurant restaurant);
  Future<Either<Failure, void>> removeFavorite(int restaurantId);
  Future<Either<Failure, bool>> isFavorite(int restaurantId);
  Future<Either<Failure, void>> clearFavorites();
}
