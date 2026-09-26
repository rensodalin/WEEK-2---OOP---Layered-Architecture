import 'package:flutter/material.dart';
import '../../model/restaurant_table.dart';

class AddTableForm extends StatefulWidget {
  final List<RestaurantTable> tables;

  const AddTableForm({
    super.key,
    this.tables = const [],
  });

  @override
  State<AddTableForm> createState() => _AddTableFormState();
}

class _AddTableFormState extends State<AddTableForm> {
  final _formkey = GlobalKey<FormState>();
  final _tableNumberController = TextEditingController();

  int _capacity = 4;

  void onAddTable() {
    if (_formkey.currentState!.validate()) {
      int tableNumber = int.parse(_tableNumberController.text);

      RestaurantTable table = RestaurantTable(
        tableNumber: tableNumber,
        capacity: _capacity,
      );

      Navigator.pop<RestaurantTable>(context, table);
    }
  }

  String? validateTableNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter table number';
    }

    int? num = int.tryParse(value);

    if (num == null || num <= 0) {
      return 'Enter a valid positive number';
    }

    for (final table in widget.tables) {
      if (table.tableNumber == num) {
        return 'Table $num already exists';
      }
    }

    return null;
  }

  @override
  void dispose() {
    _tableNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Table'),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formkey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _tableNumberController,
                    keyboardType: TextInputType.number,
                    validator: validateTableNumber,
                    decoration: const InputDecoration(
                      labelText: 'Table Number',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  DropdownButtonFormField<int>(
                    initialValue: _capacity,
                    decoration: const InputDecoration(
                      labelText: 'Capacity (Guests)',
                      border: OutlineInputBorder(),
                    ),

                    items: const [
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
                        _capacity = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onAddTable,
                      child: const Text('Add Table'),
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