import 'package:flutter/material.dart';
import '../../model/order.dart';
import '../../model/restaurant_table.dart';

class TableCard extends StatelessWidget {
  final RestaurantTable table;
  final Order? activeOrder;

  const TableCard({
    super.key,
    required this.table,
    this.activeOrder,
  });

  @override
  Widget build(BuildContext context) {
    final isOccupied = table.isOccupied;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                Icons.table_restaurant,
                size: 36,
                color: isOccupied ? Colors.red : Colors.green,
              ),

              title: Text(
                'Table ${table.tableNumber} - ${isOccupied ? "Occupied" : "Available"}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isOccupied ? Colors.red : Colors.green,
                ),
              ),

              subtitle: Text(
                isOccupied
                    ? 'Capacity: ${table.capacity} guests • Seated: ${activeOrder?.guestCount ?? 0} guests'
                    : 'Capacity: ${table.capacity} guests',
              ),
            ),

          Divider(),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isOccupied
                      ? 'Active Tab: \$${(activeOrder?.rawTotal ?? 0).toStringAsFixed(2)}'
                      : 'Table is ready',
                ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}
