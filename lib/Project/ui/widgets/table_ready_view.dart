import 'package:flutter/material.dart';
import '../../model/restaurant_table.dart';

class TableReadyView extends StatelessWidget {
  final RestaurantTable table;
  final VoidCallback onTap;

  const TableReadyView({
    super.key,
    required this.table,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.table_restaurant,
            size: 60,
            color: Colors.green,
          ),
          SizedBox(height: 10),
          Text(
            'Table is ready for guests',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
            onPressed: onTap,
            child: Text('Open Order', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
