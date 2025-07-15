import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../restaurants/domain/entities/restaurant.dart';
import '../repositories/favorites_repository.dart';

class ToggleFavoriteUseCase implements UseCase<void, Restaurant> {
  final FavoritesRepository repository;

  ToggleFavoriteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(Restaurant restaurant) async {
    final isFavoriteResult = await repository.isFavorite(restaurant.id);

    return isFavoriteResult.fold((failure) => Left(failure), (
      isFavorite,
    ) async {
      if (isFavorite) {
        return await repository.removeFavorite(restaurant.id);
      } else {
        return await repository.addFavorite(restaurant);
      }
    });
  }
}
