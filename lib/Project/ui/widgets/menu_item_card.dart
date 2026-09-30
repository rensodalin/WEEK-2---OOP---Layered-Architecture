import 'package:flutter/material.dart';
import '../../model/menu_item.dart';

class MenuItemCard extends StatelessWidget {
  final MenuItem item;

  const MenuItemCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final isBeverage = item.category == MenuCategory.beverage;

    return Card(
      child: ListTile(
        leading: Icon(
          isBeverage ? Icons.local_cafe : Icons.fastfood,
          color: isBeverage ? Colors.blue : Colors.orange,
        ),
        title: Text(item.name),
        subtitle: Text(
          isBeverage ? 'Beverage' : 'Food',
        ),
        trailing: Text(
          '\$${item.price.toStringAsFixed(2)}',
          style: TextStyle(
            color: Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}