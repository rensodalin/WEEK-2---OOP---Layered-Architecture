
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
      margin:  EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding:  EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              isBeverage ? Icons.local_cafe : Icons.fastfood,
              color: isBeverage ? Colors.blue : Colors.orange,
            ),

             SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                SizedBox(height: 4),

                  Text(
                    isBeverage ? 'Beverage' : 'Food',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            Text(
              '\$${item.price.toStringAsFixed(2)}',
              style:  TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
