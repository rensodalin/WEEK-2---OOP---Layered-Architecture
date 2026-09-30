import 'package:flutter/material.dart';

import '../../model/menu_item.dart';
import '../widgets/menu_item_card.dart';

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
  bool _showBeverageOnly = false;

  List<MenuItem> get displayBeverage => _showBeverageOnly
      ? widget.menu.where((i) => i.category == MenuCategory.beverage).toList()
      : widget.menu;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(
                  value: _showBeverageOnly,
                  onChanged: (bool? value) {
                    setState(() {
                      _showBeverageOnly = value!;
                    });
                  },
                ),
                const Text(
                  'Show beverages only',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
