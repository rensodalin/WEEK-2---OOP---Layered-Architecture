import 'package:flutter/material.dart';
import '../../model/order.dart';
import '../../model/restaurant_table.dart';

class OpenOrderForm extends StatefulWidget {
  final RestaurantTable table;

  const OpenOrderForm({
    super.key,
    required this.table,
  });

  @override
  State<OpenOrderForm> createState() => _OpenOrderFormState();
}

class _OpenOrderFormState extends State<OpenOrderForm> {
  final _formKey = GlobalKey<FormState>();

  final _guestController = TextEditingController();
  final _waiterController = TextEditingController();

  void openOrder() {
    if (_formKey.currentState!.validate()) {
      final guestCount = int.tryParse(_guestController.text)!;
      final waiterId = _waiterController.text.toUpperCase();
      final orderId = 'ORD-00${widget.table.tableNumber}';

      widget.table.occupy();

      final newOrder = Order(
        id: orderId,
        tableNumber: widget.table.tableNumber,
        waiterId: waiterId,
        guestCount: guestCount,
      );

      Navigator.pop(context, newOrder);
    }
  }

  String? validateGuests(String? value) {
    final guests = int.tryParse(value ?? '');

    if (guests == null) {
      return 'Enter guest count';
    }

    if (guests <= 0) {
      return 'Enter a valid guest count';
    }

    if (guests > widget.table.capacity) {
      return 'Cannot exceed table capacity (${widget.table.capacity})';
    }

    return null;
  }

  String? validateWaiter(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter waiter ID';
    }

    final id = value.toUpperCase();
    if (id != 'W01' && id != 'MGR01') {
      return 'Waiter $id not found';
    }

    return null;
  }

  @override
  void dispose() {
    _guestController.dispose();
    _waiterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Open Order'),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Open Order - Table ${widget.table.tableNumber}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _guestController,
                validator: validateGuests,
                decoration: InputDecoration(
                  labelText: 'Guest Count (Max ${widget.table.capacity})',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _waiterController,
                validator: validateWaiter,
                decoration: InputDecoration(
                  labelText: 'Waiter ID',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: openOrder,
                  child: Text('Open Order'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
