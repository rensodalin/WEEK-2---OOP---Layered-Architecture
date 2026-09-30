import 'package:flutter/material.dart';

import '../../model/order_item.dart';

class OrderItemTile extends StatelessWidget {
  final OrderItem item;

  const OrderItemTile({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        '${item.quantity}x',
        style:  TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      title: Text(item.menuItem.name),
      subtitle: Text(
        '${item.menuItem.id} • ${item.menuItem.category.name}',
      ),
      trailing: Text(
        '\$${item.subtotal.toStringAsFixed(2)}',
        style:  TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}