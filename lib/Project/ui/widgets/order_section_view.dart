import 'package:flutter/material.dart';
import '../../model/order.dart';
import '../widgets/order_item_tile.dart';

class OrderSectionView extends StatelessWidget {
  final Order order;
  final VoidCallback onAddItem;
  final VoidCallback onCancelOrder;
  final VoidCallback onCheckoutOrder;

  const OrderSectionView({
    super.key,
    required this.order,
    required this.onAddItem,
    required this.onCancelOrder,
    required this.onCheckoutOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Add Items
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: onAddItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF533E38),
              ),
              child: Text(
                'Add Items',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: order.items.length,
            itemBuilder: (context, index) {
              return OrderItemTile(
                item: order.items[index],
              );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtotal:',
              style: TextStyle(fontSize: 16),
            ),
            Text(
              '\$${order.rawTotal.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onCancelOrder,
                style: OutlinedButton.styleFrom(
                ),
                child: Text('Cancel Order' , style: TextStyle(color: Colors.red),),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: onCheckoutOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF533E38),

                ),
                child: Text(
                  'Check Out',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
