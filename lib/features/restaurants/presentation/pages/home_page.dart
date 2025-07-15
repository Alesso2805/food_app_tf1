import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../bloc/restaurant_bloc.dart';
import '../widgets/restaurants_tab.dart';
import '../widgets/favorites_tab.dart';

class HomePage extends StatefulWidget {
  final User user;

  const HomePage({super.key, required this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<RestaurantBloc>()),
        BlocProvider(create: (context) => sl<FavoritesBloc>()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'FoodApp',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFFFF6B6B),
          elevation: 0,
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: [
            RestaurantsTab(user: widget.user),
            FavoritesTab(user: widget.user),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: const Color(0xFFFF6B6B),
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu),
              label: 'Restaurantes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
          ],
        ),
      ),
    );
  }
}
