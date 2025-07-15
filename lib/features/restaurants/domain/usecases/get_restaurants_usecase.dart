import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

class GetRestaurantsUseCase implements UseCase<List<Restaurant>, NoParams> {
  final RestaurantRepository repository;

  GetRestaurantsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Restaurant>>> call(NoParams params) async {
    return await repository.getRestaurants();
  }
}
