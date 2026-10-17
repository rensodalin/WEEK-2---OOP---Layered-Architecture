import 'package:flutter/material.dart';

import '../../model/menu_item.dart';
import '../../model/order.dart';
import '../../model/restaurant_table.dart';

import '../widgets/order_section_view.dart';
import '../widgets/table_header_card.dart';
import '../widgets/table_ready_view.dart';
import 'add_menu_item_to_order_form.dart';
import 'open_order_form.dart';

class TableDetailScreen extends StatefulWidget {
  final RestaurantTable table;
  final List<MenuItem> menu;

  const TableDetailScreen({
    super.key,
    required this.table,
    this.menu = const [],
  });

  @override
  State<TableDetailScreen> createState() => _TableDetailScreenState();
}

class _TableDetailScreenState extends State<TableDetailScreen> {
  Order? get currentOrder => widget.table.currentOrder;

  void onAddItem() async {
    final order = currentOrder;
    if (order == null) return;

    final updatedOrder = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMenuItemToOrderForm(
          order: order,
          menu: widget.menu,
        ),
      ),
    );

    if (updatedOrder != null) {
      setState(() {});
    }
  }

  void cancelOrder() {}

  void checkoutOrder() {}

  void onTap() async {
    final newOrder = await Navigator.push<Order>(
      context,
      MaterialPageRoute(
        builder: (context) => OpenOrderForm(
          table: widget.table,
        ),
      ),
    );

    if (newOrder != null) {
      setState(() {
        widget.table.occupy(newOrder);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = currentOrder;
    final isOccupied =
        widget.table.isOccupied && order != null && order.isOpen;

    return Scaffold(
      appBar: AppBar(
        title:  Text('Restaurant System'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TableHeaderCard(
              table: widget.table,
            ),
             SizedBox(height: 12),
            if (isOccupied)
              Expanded(
                child: OrderSectionView(
                  order: order,
                  onAddItem: onAddItem,
                  onCancelOrder: cancelOrder,
                  onCheckoutOrder: checkoutOrder,
                ),
              )
            else
              TableReadyView(
                table: widget.table,
                onTap: onTap,
              ),
          ],
        ),
      ),
    );
  }
}
