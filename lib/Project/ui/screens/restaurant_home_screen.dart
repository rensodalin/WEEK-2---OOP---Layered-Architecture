import 'package:flutter/material.dart';
import '../../service/restaurant_service.dart';
import 'discounts_screen.dart';
import 'menu_screen.dart';
import 'tables_screen.dart';

class RestaurantHomeScreen extends StatelessWidget {
  final RestaurantService service;

  const RestaurantHomeScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Restaurant System'),
          centerTitle: true,
        ),
        body: TabBarView(
          children: [
            TablesScreen(
              tables: service.tables,
              orders: service.orders,
            ),
            MenuScreen(menu: service.menu),
            DiscountsScreen(discounts: service.discounts),
          ],
        ),
        bottomNavigationBar: TabBar(
          tabs: [
            Tab(icon: Icon(Icons.table_restaurant), text: 'Tables'),
            Tab(icon: Icon(Icons.restaurant_menu), text: 'Menu'),
            Tab(icon: Icon(Icons.confirmation_number_outlined), text: 'Discounts'),
          ],
        ),
      ),
    );
  }
}
