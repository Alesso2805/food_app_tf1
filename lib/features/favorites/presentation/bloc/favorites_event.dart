part of 'favorites_bloc.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object> get props => [];
}

class GetFavoritesEvent extends FavoritesEvent {}

class ToggleFavoriteEvent extends FavoritesEvent {
  final Restaurant restaurant;

  const ToggleFavoriteEvent(this.restaurant);

  @override
  List<Object> get props => [restaurant];
}
