import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/restaurant.dart';
import '../entities/comment.dart';

abstract class RestaurantRepository {
  Future<Either<Failure, List<Restaurant>>> getRestaurants();
  Future<Either<Failure, Restaurant>> getRestaurantById(int id);
  Future<Either<Failure, List<Comment>>> getCommentsByRestaurant(
    int restaurantId,
  );
  Future<Either<Failure, void>> addComment(
    int restaurantId,
    String comment,
    double rating,
  );
}
