import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Core
import 'core/network/network_info.dart';

// Features - Auth
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

// Features - Restaurants
import 'features/restaurants/data/datasources/restaurant_remote_data_source.dart';
import 'features/restaurants/data/repositories/restaurant_repository_impl.dart';
import 'features/restaurants/domain/repositories/restaurant_repository.dart';
import 'features/restaurants/domain/usecases/get_restaurants_usecase.dart';
import 'features/restaurants/domain/usecases/get_comments_usecase.dart';
import 'features/restaurants/domain/usecases/add_comment_usecase.dart';
import 'features/restaurants/presentation/bloc/restaurant_bloc.dart';

// Features - Favorites
import 'features/favorites/data/datasources/favorites_local_data_source.dart';
import 'features/favorites/data/repositories/favorites_repository_impl.dart';
import 'features/favorites/domain/repositories/favorites_repository.dart';
import 'features/favorites/domain/usecases/get_favorites_usecase.dart';
import 'features/favorites/domain/usecases/toggle_favorite_usecase.dart';
import 'features/favorites/presentation/bloc/favorites_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc(loginUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      restaurantDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );

  //! Features - Restaurants
  // Bloc
  sl.registerFactory(
    () => RestaurantBloc(
      getRestaurantsUseCase: sl(),
      getCommentsUseCase: sl(),
      addCommentUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetRestaurantsUseCase(sl()));
  sl.registerLazySingleton(() => GetCommentsUseCase(sl()));
  sl.registerLazySingleton(() => AddCommentUseCase(sl()));

  // Repository
  sl.registerLazySingleton<RestaurantRepository>(
    () => RestaurantRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<RestaurantRemoteDataSource>(
    () => RestaurantRemoteDataSourceImpl(client: sl()),
  );

  //! Features - Favorites
  // Bloc
  sl.registerFactory(
    () => FavoritesBloc(getFavoritesUseCase: sl(), toggleFavoriteUseCase: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));

  // Repository
  sl.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<FavoritesLocalDataSource>(
    () => FavoritesLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
}
