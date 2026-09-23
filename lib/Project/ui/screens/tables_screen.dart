import 'package:flutter/material.dart';
import '../../model/order.dart';
import '../../model/restaurant_table.dart';
import '../widgets/table_card.dart';

class TablesScreen extends StatelessWidget {
  final List<RestaurantTable> tables;
  final List<Order> orders;


  const TablesScreen({
    super.key,
    required this.tables,
    this.orders = const [],

  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: ListView.builder(
        itemCount: tables.length,
        itemBuilder: (context, index) {
          final table = tables[index];
          final activeOrder = orders
              .where((o) => o.tableNumber == table.tableNumber && o.isOpen)
              .firstOrNull;

          return TableCard(
            table: table,
            activeOrder: activeOrder,
          );
        },
      ),
    );
  }
}
