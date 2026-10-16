
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
  final Order? order;
  final List<MenuItem> menu;
  final List<Order>? orders;

  const TableDetailScreen({
    super.key,
    required this.table,
    this.order,
    this.menu = const [],
    this.orders,
  });

  @override
  State<TableDetailScreen> createState() =>
      _TableDetailScreenState();
}

class _TableDetailScreenState extends State<TableDetailScreen> {
  // Open a new order
  void openOrder() async {
    final newOrder = await Navigator.push<Order>(
      context,
      MaterialPageRoute(
        builder: (context) => OpenOrderForm(
          table: widget.table,
        ),
      ),
    );

    if (newOrder == null) return;

    widget.orders?.add(newOrder);

    setState(() {});
  }

  // Add food to the order
  void addItem() async {
    if (widget.order == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMenuItemToOrderForm(
          order: widget.order!,
          menu: widget.menu,
        ),
      ),
    );

    setState(() {});
  }

  // Cancel the order
  void cancelOrder() {
    if (widget.order == null || widget.order!.isPaid) return;

    widget.order!.cancel();
    widget.table.release();

    setState(() {});
  }

  // Checkout the order
  void checkoutOrder() {
    if (widget.order == null || widget.order!.items.isEmpty) return;

    widget.order!.markPaid();
    widget.table.release();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    final isOccupied =
        widget.table.isOccupied &&
        order != null &&
        order.isOpen;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant System'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TableHeaderCard(
              table: widget.table,
              order: order,
            ),
            const SizedBox(height: 12),

            if (isOccupied)
              Expanded(
                child: OrderSectionView(
                  order: order,
                  onAddItem: addItem,
                  onCancelOrder: cancelOrder,
                  onCheckoutOrder: checkoutOrder,
                ),
              )
            else
              TableReadyView(
                table: widget.table,
                onTap: openOrder,
              ),
          ],
        ),
      ),
    );
  }
}
