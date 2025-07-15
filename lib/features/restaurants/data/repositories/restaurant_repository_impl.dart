import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_remote_data_source.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  RestaurantRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Restaurant>>> getRestaurants() async {
    if (await networkInfo.isConnected) {
      try {
        final restaurants = await remoteDataSource.getRestaurants();
        return Right(restaurants);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, Restaurant>> getRestaurantById(int id) async {
    if (await networkInfo.isConnected) {
      try {
        final restaurant = await remoteDataSource.getRestaurantById(id);
        return Right(restaurant);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, List<Comment>>> getCommentsByRestaurant(
    int restaurantId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final comments = await remoteDataSource.getCommentsByRestaurant(
          restaurantId,
        );
        return Right(comments);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }

  @override
  Future<Either<Failure, void>> addComment(
    int restaurantId,
    String comment,
    double rating,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.addComment(restaurantId, comment, rating);
        return const Right(null);
      } catch (e) {
        return Left(ServerFailure(e.toString()));
      }
    } else {
      return const Left(NetworkFailure('No internet connection'));
    }
  }
}
