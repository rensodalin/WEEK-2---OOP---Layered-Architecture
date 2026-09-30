import 'package:flutter/material.dart';
import '../../model/order.dart';
import '../../model/restaurant_table.dart';

class TableCard extends StatelessWidget {
  final RestaurantTable table;
  final Order? activeOrder;
  final VoidCallback? onTap;
  final bool isSelected;

  const TableCard({
    super.key,
    required this.table,
    this.activeOrder,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ?  Color(0xFFEFEBE9) : Colors.white,
      margin:  EdgeInsets.symmetric(vertical: 6),
      elevation: isSelected ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.brown : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                Icons.table_restaurant,
                size: 32,
                color: table.isOccupied ? Colors.red : Colors.green,
              ),
               SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Table ${table.tableNumber}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                   SizedBox(height: 4),
                    Text(
                      'Capacity: ${table.capacity} guests',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
