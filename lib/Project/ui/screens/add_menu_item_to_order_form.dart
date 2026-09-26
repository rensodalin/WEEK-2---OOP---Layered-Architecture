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
  State<AddMenuItemToOrderForm> createState() =>
      _AddMenuItemToOrderFormState();
}

class _AddMenuItemToOrderFormState extends State<AddMenuItemToOrderForm> {
  final _qtyController = TextEditingController();

  MenuItem? _selectedItem;//Remember which menu item the user is currently selecting to add.

  @override
  void initState() {
    super.initState();

    if (widget.menu.isNotEmpty) {
      _selectedItem = widget.menu.first;
    }
  }

  void addItem() {
    final quantity = int.tryParse(_qtyController.text) ?? 1;

    if (_selectedItem == null) {
      return;
    }

    final item = OrderItem(
      menuItem: _selectedItem!,
      quantity: quantity,
    );

    Navigator.pop(context, item);
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Item - Table ${widget.order.tableNumber}',
        ),
      ),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<MenuItem>(
              initialValue: _selectedItem,
              decoration: InputDecoration(
                labelText: 'Select Menu Item',
                border: OutlineInputBorder(),
              ),

              items: widget.menu.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    '${item.name} (\$${item.price.toStringAsFixed(2)})',
                  ),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  _selectedItem = value;
                });
              },
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _qtyController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addItem,
                child: const Text('Add to Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}