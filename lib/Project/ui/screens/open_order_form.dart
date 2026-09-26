import 'package:flutter/material.dart';
import '../../model/order.dart';
import '../../model/restaurant_table.dart';
import '../../service/restaurant_service.dart';

class OpenOrderForm extends StatefulWidget {
  final RestaurantTable table;
  final RestaurantService? service;

  const OpenOrderForm({
    super.key,
    required this.table,
    this.service,
  });

  @override
  State<OpenOrderForm> createState() => _OpenOrderFormState();
}

class _OpenOrderFormState extends State<OpenOrderForm> {
  final _formKey = GlobalKey<FormState>();
  final _orderIdController = TextEditingController();
  final _waiterIdController = TextEditingController(text: 'W01');
  int _guestCount = 1;

  @override
  void initState() {
    super.initState();
    final nextNum = (widget.service?.orders.length ?? 0) + 1;
    _orderIdController.text = 'ORD-${nextNum.toString().padLeft(3, '0')}';
  }

  void onOpenOrder() {
    if (_formKey.currentState!.validate()) {
      final orderId = _orderIdController.text.trim();
      final waiterId = _waiterIdController.text.trim();

      try {
        if (widget.service != null) {
          widget.service!.openOrder(
            orderId: orderId,
            tableNumber: widget.table.tableNumber,
            guestCount: _guestCount,
            waiterId: waiterId,
          );
          final createdOrder =
              widget.service!.orders.firstWhere((o) => o.id == orderId);
          Navigator.pop<Order>(context, createdOrder);
        } else {
          if (widget.table.isOccupied) {
            throw Exception('Table ${widget.table.tableNumber} is already occupied');
          }
          if (_guestCount <= 0) {
            throw Exception('Guest count must be greater than 0');
          }
          if (_guestCount > widget.table.capacity) {
            throw Exception(
              'Guest count ($_guestCount) exceeds table capacity (${widget.table.capacity})',
            );
          }
          widget.table.occupy();
          final order = Order(
            id: orderId,
            tableNumber: widget.table.tableNumber,
            waiterId: waiterId,
            guestCount: _guestCount,
          );
          Navigator.pop<Order>(context, order);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String? validateOrderId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter an order ID';
    }
    if (widget.service != null) {
      final exists = widget.service!.orders.any((o) => o.id == value.trim());
      if (exists) {
        return 'Order ${value.trim()} already exists';
      }
    }
    return null;
  }

  String? validateWaiterId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter waiter ID';
    }
    if (widget.service != null) {
      final staff = widget.service!.staffMembers
          .where((s) => s.id == value.trim())
          .firstOrNull;
      if (staff == null) {
        return 'Staff member ${value.trim()} not found';
      }
      if (!staff.isWaiter && !staff.isManager) {
        return 'Staff member ${value.trim()} is not authorized to open orders';
      }
    }
    return null;
  }

  @override
  void dispose() {
    _orderIdController.dispose();
    _waiterIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Open Order - Table ${widget.table.tableNumber}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Open Order for Table ${widget.table.tableNumber}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              'Capacity: ${widget.table.capacity} guests max',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 15),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _orderIdController,
                    validator: validateOrderId,
                    decoration: const InputDecoration(
                      labelText: 'Order ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _waiterIdController,
                    validator: validateWaiterId,
                    decoration: const InputDecoration(
                      labelText: 'Waiter ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    initialValue: _guestCount,
                    decoration: const InputDecoration(
                      labelText: 'Guest Count',
                      border: OutlineInputBorder(),
                    ),
                    items: List.generate(
                      widget.table.capacity,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text(
                          '${index + 1} ${index == 0 ? "guest" : "guests"}',
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _guestCount = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onOpenOrder,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF533E38),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Open Order'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
