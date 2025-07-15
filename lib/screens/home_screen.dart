import 'package:flutter/material.dart';
import '../models/user.dart';
import 'restaurants_tab.dart';
import 'favorites_tab.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'FoodApp',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: const Color(0xFFFF6B6B),
          automaticallyImplyLeading: false,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(icon: Icon(Icons.restaurant), text: 'Restaurantes'),
              Tab(icon: Icon(Icons.favorite), text: 'Favoritos'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RestaurantsTab(user: widget.user),
            FavoritesTab(user: widget.user),
          ],
        ),
      ),
    );
  }
}
