import 'package:flutter/material.dart';
import '../../model/menu_item.dart';
import '../widgets/menu_item_card.dart';

/// Screen displaying the restaurant menu catalogue
class MenuScreen extends StatelessWidget {
  final List<MenuItem> menu;

  const MenuScreen({super.key, required this.menu});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: ListView.builder(
        itemCount: menu.length,
        itemBuilder: (context, index) => MenuItemCard(item: menu[index]),
      ),
    );
  }
}
