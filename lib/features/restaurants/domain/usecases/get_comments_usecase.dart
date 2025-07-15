import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/comment.dart';
import '../repositories/restaurant_repository.dart';

class GetCommentsUseCase implements UseCase<List<Comment>, int> {
  final RestaurantRepository repository;

  GetCommentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Comment>>> call(int restaurantId) async {
    return await repository.getCommentsByRestaurant(restaurantId);
  }
}
