import 'package:flutter/material.dart';
import '../../model/restaurant_table.dart';

class AddTableForm extends StatefulWidget {
  final List<RestaurantTable> tables;

  const AddTableForm({
    super.key,
    required this.tables,
  });

  @override
  State<AddTableForm> createState() => _AddTableFormState();
}

class _AddTableFormState extends State<AddTableForm> {
  final _formKey = GlobalKey<FormState>();
  final _tableController = TextEditingController();

  int capacity = 4;

  void addTable() {
    if (_formKey.currentState!.validate()) {
      final table = int.tryParse(_tableController.text)!;

      final newTable = RestaurantTable(
        tableNumber: table,
        capacity: capacity,
      );

      Navigator.pop(context, newTable);
    }
  }

  String? validateTable(String? value) {
    final number = int.tryParse(value ?? '');

    if (number == null) {
      return 'Enter table number';
    }

    if (number <= 0) {
      return 'Enter a valid table number';
    }

    for (final table in widget.tables) {
      if (table.tableNumber == number) {
        return 'Table already exists';
      }
    }

    return null;
  }

  @override
  void dispose() {
    _tableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Table'),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Add New Dining Table',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _tableController,
                validator: validateTable,
                decoration: InputDecoration(
                  labelText: 'Table Number',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: capacity,
                decoration: InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 2,
                    child: Text('2 guests'),
                  ),
                  DropdownMenuItem(
                    value: 4,
                    child: Text('4 guests'),
                  ),
                  DropdownMenuItem(
                    value: 6,
                    child: Text('6 guests'),
                  ),
                  DropdownMenuItem(
                    value: 8,
                    child: Text('8 guests'),
                  ),
                  DropdownMenuItem(
                    value: 10,
                    child: Text('10 guests'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    capacity = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: addTable,
                  child: Text('Add Table'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
