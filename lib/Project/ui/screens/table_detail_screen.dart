import 'package:flutter/material.dart';

import '../../model/order.dart';
import '../../model/order_item.dart';
import '../../model/restaurant_table.dart';
import '../../service/restaurant_service.dart';

import '../widgets/order_section_view.dart';
import '../widgets/table_header_card.dart';
import '../widgets/table_ready_view.dart';

import 'add_menu_item_to_order_form.dart';
import 'open_order_form.dart';

class TableDetailScreen extends StatefulWidget {
  final RestaurantTable table;
  final Order? order;
  final RestaurantService? service;

  const TableDetailScreen({
    super.key,
    required this.table,
    this.order,
    this.service,
  });

  @override
  State<TableDetailScreen> createState() => _TableDetailScreenState();
}

class _TableDetailScreenState extends State<TableDetailScreen> {
  Order? order;

  @override
  void initState() {
    super.initState();

    order = widget.order;

    if (order == null && widget.service != null) {
      for (final item in widget.service!.orders) {
        if (item.tableNumber == widget.table.tableNumber &&
            item.isOpen) {
          order = item;
          break;
        }
      }
    }
  }

  void openOrder() async {
    final newOrder = await Navigator.push<Order>(
      context,
      MaterialPageRoute(
        builder: (context) => OpenOrderForm(
          table: widget.table,
          service: widget.service,
        ),
      ),
    );

    if (newOrder != null) {
      setState(() {
        order = newOrder;
      });
    }
  }

  void addItem() async {
    if (order == null) {
      return;
    }

    final menu = widget.service?.menu ?? [];

    if (menu.isEmpty) {
      return;
    }

    final newItem = await Navigator.push<OrderItem>(
      context,
      MaterialPageRoute(
        builder: (context) => AddMenuItemToOrderForm(
          order: order!,
          menu: menu,
        ),
      ),
    );

    if (newItem != null) {
      setState(() {
        order!.addItem(newItem);
      });
    }
  }

  void cancelOrder() {
    if (order == null) {
      return;
    }

    if (widget.service != null) {
      widget.service!.cancelOrder(
        waiterId: order!.waiterId,
        orderId: order!.id,
      );
    } else {
      if (order!.isPaid) {
        return;
      }

      widget.table.release();
      order!.cancel();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Order #${order!.id} has been cancelled',
        ),
      ),
    );

    Navigator.pop(context);
  }

  void checkoutOrder() {
    if (order == null) {
      return;
    }

    if (widget.service != null) {
      widget.service!.checkoutOrder(
        orderId: order!.id,
        cashierId: 'K01',
      );
    } else {
      if (order!.items.isEmpty) {
        return;
      }

      widget.table.release();
      order!.markPaid();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Order #${order!.id} checked out successfully',
        ),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isOccupied =
        widget.table.isOccupied &&
        order != null &&
        order!.isOpen;

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
                  order: order!,
                  onAddItem: addItem,
                  onCancelOrder: cancelOrder,
                  onCheckoutOrder: checkoutOrder,
                ),
              )
            else
              Expanded(
                child: TableReadyView(
                  table: widget.table,
                  onTap: openOrder,
                ),
              ),
          ],
        ),
      ),
    );
  }
}