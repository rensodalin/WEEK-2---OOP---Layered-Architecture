// import 'package:flutter/material.dart';
// import '../../model/menu_item.dart';
// import '../../model/order.dart';
// import '../../model/order_item.dart';

// class AddMenuItemToOrderForm extends StatefulWidget {
//   final Order order;
//   final List<MenuItem> menu;

//   const AddMenuItemToOrderForm({
//     super.key,
//     required this.order,
//     required this.menu,
//   });

//   @override
//   State<AddMenuItemToOrderForm> createState() => _AddMenuItemToOrderFormState();
// }

// class _AddMenuItemToOrderFormState extends State<AddMenuItemToOrderForm> {
//   final _qtyController = TextEditingController();
//   MenuItem? _selectedItem;
//   @override
//   void initState() {
//     super.initState();

//     if (widget.menu.isNotEmpty) {
//       _selectedItem = widget.menu.first;
//     }
//   }

//   void _onAddItem() {
//     final qty = int.tryParse(_qtyController.text) ?? 1;

//     if (_selectedItem != null) {
//       Navigator.pop(
//         context,
//         OrderItem(
//           menuItem: _selectedItem!,
//           quantity: qty,
//         ),
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _qtyController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Add Item - Table ${widget.order.tableNumber}',
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             DropdownButtonFormField<MenuItem>(
//               initialValue: _selectedItem,
//               decoration: const InputDecoration(
//                 labelText: 'Select Menu Item',
//                 border: OutlineInputBorder(),
//               ),
//               items: widget.menu.map((item) {
//                 return DropdownMenuItem(
//                   value: item,
//                   child: Text(
//                     '${item.name} (\$${item.price.toStringAsFixed(2)})',
//                   ),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   _selectedItem = value;
//                 });
//               },
//             ),
//             const SizedBox(height: 16),
//             TextField(
//               controller: _qtyController,
//               keyboardType: TextInputType.number,
//               decoration: const InputDecoration(
//                 labelText: 'Quantity',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _onAddItem,
//                 child: const Text('Add to Order'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
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
  final Map<MenuItem, int> quantities = {}; // store current qty

  @override
  void initState() {
    super.initState();

    for (var item in widget.menu) {
      quantities[item] = 0; //it set menu qty to 0
    }

    for (var orderItem in widget.order.items) {
      quantities[orderItem.menuItem] =
          orderItem.quantity; // load existing order qty
    }
  }

  void increaseQuantity(MenuItem item) {
    setState(() {
      quantities[item] = quantities[item]! + 1;
    });
  }

  void decreaseQuantity(MenuItem item) {
    setState(() {
      if (quantities[item]! > 0) {
        quantities[item] = quantities[item]! - 1;
      }
    });
  }

  double get subtotal {
    double total = 0;

    for (var i in widget.menu) {
      total += i.price * quantities[i]!;
    }

    return total;
  }

  void saveOrder() {
    widget.order.items.clear(); // clear or remove item currenly instide order

    for (var m in widget.menu) {
      final quantity = quantities[m]!; // get the qty

      if (quantity > 0) {
        widget.order.items.add(
          OrderItem(
            menuItem: m,
            quantity: quantity,
          ),
        );
      }
    }
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
                final quantity = quantities[item]!;

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
                onPressed: saveOrder,
                child: Text(
                  'Save Order \$${subtotal.toStringAsFixed(2)}',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
