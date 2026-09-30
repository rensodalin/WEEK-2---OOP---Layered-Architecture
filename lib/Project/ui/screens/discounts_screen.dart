import 'package:flutter/material.dart';
import '../../model/discount.dart';
import '../widgets/discount_card.dart';

/// Screen displaying promotional discount vouchers
class DiscountsScreen extends StatelessWidget {
  final List<Discount> discounts;

  const DiscountsScreen({
    super.key,
    required this.discounts,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView.builder(
          itemCount: discounts.length,
          itemBuilder: (context, index) {
            return DiscountCard(
              discount: discounts[index],
            );
          },
        ),
      ),
    );
  }
}
