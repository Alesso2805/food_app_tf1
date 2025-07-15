import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../restaurants/domain/entities/restaurant.dart';
import '../repositories/favorites_repository.dart';

class GetFavoritesUseCase implements UseCase<List<Restaurant>, NoParams> {
  final FavoritesRepository repository;

  GetFavoritesUseCase(this.repository);

  @override
  Future<Either<Failure, List<Restaurant>>> call(NoParams params) async {
    return await repository.getFavorites();
  }
}
