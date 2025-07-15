import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/entities/comment.dart';
import '../../domain/usecases/get_restaurants_usecase.dart';
import '../../domain/usecases/get_comments_usecase.dart';
import '../../domain/usecases/add_comment_usecase.dart';

part 'restaurant_event.dart';
part 'restaurant_state.dart';

class RestaurantBloc extends Bloc<RestaurantEvent, RestaurantState> {
  final GetRestaurantsUseCase getRestaurantsUseCase;
  final GetCommentsUseCase getCommentsUseCase;
  final AddCommentUseCase addCommentUseCase;

  RestaurantBloc({
    required this.getRestaurantsUseCase,
    required this.getCommentsUseCase,
    required this.addCommentUseCase,
  }) : super(RestaurantInitial()) {
    on<GetRestaurantsEvent>(_onGetRestaurants);
    on<GetCommentsEvent>(_onGetComments);
    on<AddCommentEvent>(_onAddComment);
  }

  Future<void> _onGetRestaurants(
    GetRestaurantsEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantLoading());

    final result = await getRestaurantsUseCase(const NoParams());

    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (restaurants) => emit(RestaurantsLoaded(restaurants)),
    );
  }

  Future<void> _onGetComments(
    GetCommentsEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantLoading());

    final result = await getCommentsUseCase(event.restaurantId);

    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (comments) => emit(CommentsLoaded(comments)),
    );
  }

  Future<void> _onAddComment(
    AddCommentEvent event,
    Emitter<RestaurantState> emit,
  ) async {
    emit(RestaurantLoading());

    final params = AddCommentParams(
      restaurantId: event.restaurantId,
      comment: event.comment,
      rating: event.rating,
    );

    final result = await addCommentUseCase(params);

    result.fold(
      (failure) => emit(RestaurantError(failure.message)),
      (_) => emit(CommentAdded()),
    );
  }
}
