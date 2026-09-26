// import 'package:flutter/material.dart';
// import '../../model/order.dart';
// import '../../model/restaurant_table.dart';
// import '../../service/restaurant_service.dart';
// import '../widgets/table_card.dart';
// import 'add_table_form.dart';
// import 'table_detail_screen.dart';

// class TablesScreen extends StatefulWidget {
//   final List<RestaurantTable> tables;
//   final List<Order> orders;
//   final RestaurantService? service;

//   const TablesScreen({
//     super.key,
//     required this.tables,
//     this.orders = const [],
//     this.service,
//   });

//   @override
//   State<TablesScreen> createState() => _TablesScreenState();
// }

// class _TablesScreenState extends State<TablesScreen> {
//   void addnewtable() async {
//     RestaurantTable? table = await Navigator.push<RestaurantTable>(
//       context,
//       MaterialPageRoute(
//         builder: (context) => AddTableForm(tables: widget.tables),
//       ),
//     );
//     if (table != null) {
//       setState(() {
//         widget.tables.add(table);
//       });
//     }
//   }

//   void ontap(RestaurantTable table, Order? activeOrder) async {
//     final ontap = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => TableDetailScreen(
//           table: table,
//           order: activeOrder,
//           service: widget.service,
//         ),
//       ),
//     );
//     if (ontap == null) {
//       setState(() {});
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: FloatingActionButton(
//         onPressed: addnewtable,
//         child: const Icon(Icons.add),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(15),
//         child: ListView.builder(
//           itemCount: widget.tables.length,
//           itemBuilder: (context, index) {
//             final table = widget.tables[index];
//             final activeOrder = widget.orders
//                 .where((o) => o.tableNumber == table.tableNumber && o.isOpen)
//                 .firstOrNull;

//             return TableCard(
//               table: table,
//               activeOrder: activeOrder,
//               onTap: () => ontap(table, activeOrder),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../../model/order.dart';
import '../../model/restaurant_table.dart';
import '../../service/restaurant_service.dart';
import '../widgets/table_card.dart';
import 'table_detail_screen.dart';

class TablesScreen extends StatefulWidget {
  final List<RestaurantTable> tables;
  final List<Order> orders;
  final RestaurantService? service;

  const TablesScreen({
    super.key,
    required this.tables,
    this.orders = const [],
    this.service,
  });

  @override
  State<TablesScreen> createState() => _TablesScreenState();
}

class _TablesScreenState extends State<TablesScreen> {
  // false = show all tables
  // true = show only available tables
  bool _showAvailableOnly = false;

  void changeAvailableFilter(bool value) {
    setState(() {
      _showAvailableOnly = value;
    });
  }

  List<RestaurantTable> get displayedTables {
    if (!_showAvailableOnly) {
      return widget.tables;
    }

    return widget.tables.where((table) {
      return !table.isOccupied;
    }).toList();
  }

  void ontap(RestaurantTable table, Order? activeOrder) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TableDetailScreen(
          table: table,
          order: activeOrder,
          service: widget.service,
        ),
      ),
    );

    if (result == null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            // Checkbox
            Row(
              children: [
                Checkbox(
                  value: _showAvailableOnly,
                  onChanged: (value) {
                    changeAvailableFilter(value ?? false);
                  },
                ),

                const Text(
                  'Show available tables only',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Table list
            Expanded(
              child: ListView.builder(
                itemCount: displayedTables.length,
                itemBuilder: (context, index) {
                  final table = displayedTables[index];

                  final activeOrder = widget.orders
                      .where(
                        (order) =>
                            order.tableNumber == table.tableNumber &&
                            order.isOpen,
                      )
                      .firstOrNull;

                  return TableCard(
                    table: table,
                    activeOrder: activeOrder,
                    onTap: () {
                      ontap(table, activeOrder);
                    },
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
