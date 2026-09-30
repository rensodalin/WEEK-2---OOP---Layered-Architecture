import 'package:flutter/material.dart';

import '../../model/order.dart';
import '../../model/restaurant_table.dart';
import '../widgets/table_card.dart';

class TablesScreen extends StatefulWidget {
  final List<RestaurantTable> tables;
  final List<Order> orders;

  const TablesScreen({
    super.key,
    required this.tables,
    this.orders = const [],
  });

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  bool isAvailable = false;

  List<RestaurantTable> get list => isAvailable
      ? widget.tables.where((t) => !t.isOccupied).toList()
      : widget.tables;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: isAvailable,
                  onChanged: (bool? value) {
                    setState(() {
                      isAvailable = value!;
                    });
                  },
                ),
                SizedBox(width: 10),
                Text(
                  'Show available tables only',
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final tableItem = list[index];

                  final activeOrder = widget.orders
                      .where(
                        (order) =>
                            order.tableNumber == tableItem.tableNumber &&
                            order.isOpen,
                      )
                      .firstOrNull;

                  return TableCard(
                    table: tableItem,
                    activeOrder: activeOrder,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
