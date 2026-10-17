import 'package:flutter/material.dart';
import '../../model/order.dart';
import '../../model/restaurant_table.dart';

class TableHeaderCard extends StatelessWidget {
  final RestaurantTable table;
  final Order? order;

  const TableHeaderCard({
    super.key,
    required this.table,
    this.order,
  });

  @override
  Widget build(BuildContext context) {
    final activeOrder = order ?? table.currentOrder;
    final isOccupied =
        table.isOccupied && activeOrder != null && activeOrder.isOpen;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.brown[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isOccupied)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    activeOrder.id,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                )
              else
                const SizedBox(width: 40),
              Text(
                'Table ${table.tableNumber}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isOccupied ? Colors.red[100] : Colors.green[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isOccupied ? 'Occupied' : 'Available',
                  style: TextStyle(
                    color: isOccupied ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            isOccupied
                ? 'Capacity: ${table.capacity} guests  Seat : ${activeOrder.guestCount} guest'
                : 'Capacity: ${table.capacity} guests',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
