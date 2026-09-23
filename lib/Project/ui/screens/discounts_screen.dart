import 'package:flutter/material.dart';
import '../../model/discount.dart';
import '../widgets/discount_card.dart';

/// Screen displaying promotional discount vouchers
class DiscountsScreen extends StatelessWidget {
  final List<Discount> discounts;

  const DiscountsScreen({super.key, required this.discounts});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: ListView.builder(
        itemCount: discounts.length,
        itemBuilder: (context, index) => DiscountCard(discount: discounts[index]),
      ),
    );
  }
}
