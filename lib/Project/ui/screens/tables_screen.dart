import 'package:flutter/material.dart';

import '../../model/menu_item.dart';
import '../../model/order.dart';
import '../../model/restaurant_table.dart';
import '../widgets/table_card.dart';
import 'add_table_form.dart';
import 'table_detail_screen.dart';

class TablesScreen extends StatefulWidget {
  final List<RestaurantTable> tables;
  final List<Order> orders;
  final List<MenuItem> menu;

  const TablesScreen({
    super.key,
    required this.tables,
    this.orders = const [],
    this.menu = const [],
  });

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  bool isAvailable = false;

  List<RestaurantTable> get list => isAvailable
      ? widget.tables.where((t) => !t.isOccupied).toList()
      : widget.tables;

  void ontap(RestaurantTable table) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TableDetailScreen(
          table: table,
          menu: widget.menu,
        ),
      ),
    );

    if (table.currentOrder != null &&
        !widget.orders.contains(table.currentOrder!)) {
      widget.orders.add(table.currentOrder!);
    }

    setState(() {});
  }

  void addTable() async {
    final newTable = await Navigator.push<RestaurantTable>(
      context,
      MaterialPageRoute(
        builder: (context) => AddTableForm(
          tables: widget.tables,
        ),
      ),
    );

    if (newTable != null) {
      setState(() {
        widget.tables.add(newTable);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: addTable,
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
                    onTap: () => ontap(tableItem),
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
