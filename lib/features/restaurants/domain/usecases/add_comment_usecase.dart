import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/restaurant_repository.dart';

class AddCommentUseCase implements UseCase<void, AddCommentParams> {
  final RestaurantRepository repository;

  AddCommentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(AddCommentParams params) async {
    return await repository.addComment(
      params.restaurantId,
      params.comment,
      params.rating,
    );
  }
}

class AddCommentParams {
  final int restaurantId;
  final String comment;
  final double rating;

  AddCommentParams({
    required this.restaurantId,
    required this.comment,
    required this.rating,
  });
}
