import 'package:flutter/material.dart';
import '../../model/menu_item.dart';

class AddMenuItemForm extends StatefulWidget {
  const AddMenuItemForm({super.key});

  @override
  State<AddMenuItemForm> createState() => _AddMenuItemFormState();
}

class _AddMenuItemFormState extends State<AddMenuItemForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  MenuCategory category = MenuCategory.food;

  void addItem() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text;
      final price = double.tryParse(_priceController.text)!;
      final ID =
          'M${DateTime.now().millisecondsSinceEpoch}'; // it create ID for menu item , then it get the current time

      final item =
          MenuItem(id: ID, name: name, price: price, category: category);

      Navigator.pop(context, item);
    }
  }

  String? validatePrice(String? value) {
    final price = double.tryParse(value ?? '');

    if (price == null) {
      return 'Enter a valid price';
    }

    if (price <= 0) {
      return 'Price must be greater than 0';
    }

    return null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Menu Item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Add New Menu Item',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  label: Text('Item Name'),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter item name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _priceController,
                validator: validatePrice,
                decoration: InputDecoration(
                  label: Text('Price'),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              DropdownButtonFormField<MenuCategory>(
                initialValue: category,
                decoration: InputDecoration(
                  label: Text('Catagory'),
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: MenuCategory.food,
                    child: Text('Food'),
                  ),
                  DropdownMenuItem(
                    value: MenuCategory.beverage,
                    child: Text('Beverage'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    category = value!;
                  });
                },
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: addItem,
                  child: Text('Add Item'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
