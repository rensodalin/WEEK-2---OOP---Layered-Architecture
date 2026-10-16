import 'package:flutter/material.dart';
import '../../model/menu_item.dart';
import '../../model/order.dart';
import '../../model/order_item.dart';

class AddMenuItemToOrderForm extends StatefulWidget {
  final Order order;
  final List<MenuItem> menu;

  const AddMenuItemToOrderForm({
    super.key,
    required this.order,
    required this.menu,
  });

  @override
  State<AddMenuItemToOrderForm> createState() => _AddMenuItemToOrderFormState();
}

class _AddMenuItemToOrderFormState extends State<AddMenuItemToOrderForm> {
  int getQuantity(MenuItem item) {
    for (final orderItem in widget.order.items) {
      if (orderItem.menuItem.id == item.id) {
        return orderItem.quantity;
      }
    }

    return 0;
  }

  void increaseQuantity(MenuItem item) {
    setState(() {
      for (var orderItem in widget.order.items) {
        if (orderItem.menuItem.id == item.id) {
          orderItem.quantity++;
          return;
        }
      }

      widget.order.addItem(
        OrderItem(
          menuItem: item,
          quantity: 1,
        ),
      );
    });
  }

  void decreaseQuantity(MenuItem item) {
    setState(() {
      for (var orderItem in widget.order.items) {
        if (orderItem.menuItem.id == item.id) {
          if (orderItem.quantity > 1) {
            orderItem.quantity--;
          } else {
            widget.order.removeItem(item.id);
          }

          return;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order - Table ${widget.order.tableNumber}',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: widget.menu.length,
              itemBuilder: (context, index) {
                final item = widget.menu[index];

                final quantity = getQuantity(item);

                final isBeverage = item.category == MenuCategory.beverage;

                return Card(
                  child: ListTile(
                    leading: Icon(
                      isBeverage ? Icons.local_cafe : Icons.fastfood,
                      color: isBeverage ? Colors.blue : Colors.orange,
                    ),
                    title: Text(item.name),
                    subtitle: Text(
                      '\$${item.price.toStringAsFixed(2)}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: quantity > 0
                              ? () => decreaseQuantity(item)
                              : null,
                          icon: Icon(Icons.remove),
                        ),
                        Text(
                          '$quantity',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => increaseQuantity(item),
                          icon: Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, widget.order);
                },
                child: Text(
                  'Save Order \$${widget.order.rawTotal.toStringAsFixed(2)}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
