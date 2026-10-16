
import 'package:flutter/material.dart';
import '../../model/order.dart';
import '../../model/restaurant_table.dart';

class TableCard extends StatelessWidget {
  final RestaurantTable table;
  final Order? activeOrder;
  final VoidCallback? onTap;

   TableCard({
    super.key,
    required this.table,
    this.activeOrder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isOccupied = table.isOccupied;

    return Card(
      color: Colors.white,
      margin:  EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        
        onTap: onTap,
        contentPadding:  EdgeInsets.symmetric( horizontal: 16, vertical: 8, ),

        leading: Icon(
          Icons.table_restaurant,
          size: 36,
          color: isOccupied ? Colors.red : Colors.green,
        ),

        title: Text(
          'Table ${table.tableNumber} - '
          '${isOccupied ? "Occupied" : "Available"}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isOccupied ? Colors.red : Colors.green,
          ),
        ),

       subtitle: Text( isOccupied ? 'Capacity: ${table.capacity} guests ': 'Capacity: ${table.capacity} guests', ),
      ),
    );
  }
}
