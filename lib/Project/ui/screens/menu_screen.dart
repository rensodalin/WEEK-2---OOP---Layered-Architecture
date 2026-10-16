import 'package:flutter/material.dart';

import '../../model/menu_item.dart';
import '../widgets/menu_item_card.dart';
import 'add_menu_item_form.dart';

class MenuScreen extends StatefulWidget {
  final List<MenuItem> menu;

  const MenuScreen({
    super.key,
    required this.menu,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool showBeverageOnly = false;

  List<MenuItem> get displayBeverage => showBeverageOnly
      ? widget.menu.where((i) => i.category == MenuCategory.beverage).toList()
      : widget.menu;

  void addMenuItem() async {
    final newItem = await Navigator.push<MenuItem>(
      context,
      MaterialPageRoute(
        builder: (context) => AddMenuItemForm(),
      ),
    );
    if (newItem != null) {
      setState(() {
        widget.menu.add(newItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: addMenuItem,
        child: Icon(Icons.add),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: showBeverageOnly,
                  onChanged: (bool? value) {
                    setState(() {
                      showBeverageOnly = value!;
                    });
                  },
                ),
                Text(
                  'Show beverages only',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: displayBeverage.length,
                itemBuilder: (context, index) {
                  final item = displayBeverage[index];

                  return MenuItemCard(
                    item: item,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
