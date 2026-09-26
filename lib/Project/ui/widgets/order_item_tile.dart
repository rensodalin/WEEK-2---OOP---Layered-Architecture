import 'package:flutter/material.dart';
import '../../model/order_item.dart';

class OrderItemTile extends StatelessWidget {
  final OrderItem item;
  final VoidCallback? onIncrease;
  final VoidCallback? onDecrease;

  const OrderItemTile({
    super.key,
    required this.item,
    this.onIncrease,
    this.onDecrease,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(
        '${item.quantity}x',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      title: Text(item.menuItem.name),
      subtitle: Text(
        '${item.menuItem.id} • ${item.menuItem.category.name}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onDecrease != null)
            IconButton(
              onPressed: onDecrease,
              icon: const Icon(Icons.remove),
            ),
          Text(
            '${item.quantity}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (onIncrease != null)
            IconButton(
              onPressed: onIncrease,
              icon: const Icon(Icons.add),
            ),
          const SizedBox(width: 10),
          Text(
            '\$${item.subtotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}