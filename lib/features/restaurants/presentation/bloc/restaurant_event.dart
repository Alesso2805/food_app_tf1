part of 'restaurant_bloc.dart';

abstract class RestaurantEvent extends Equatable {
  const RestaurantEvent();

  @override
  List<Object> get props => [];
}

class GetRestaurantsEvent extends RestaurantEvent {}

class GetCommentsEvent extends RestaurantEvent {
  final int restaurantId;

  const GetCommentsEvent(this.restaurantId);

  @override
  List<Object> get props => [restaurantId];
}

class AddCommentEvent extends RestaurantEvent {
  final int restaurantId;
  final String comment;
  final double rating;

  const AddCommentEvent({
    required this.restaurantId,
    required this.comment,
    required this.rating,
  });

  @override
  List<Object> get props => [restaurantId, comment, rating];
}
