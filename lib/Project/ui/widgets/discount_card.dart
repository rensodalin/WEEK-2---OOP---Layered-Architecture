import 'package:flutter/material.dart';
import 'chib/discount_chip.dart';
import '../../model/discount.dart';

class DiscountCard extends StatelessWidget {
  final Discount discount;

  const DiscountCard({super.key, required this.discount});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              color: Colors.deepOrange,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    discount.code,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Min. order: \$${discount.minOrderAmount.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            DiscountChip(discount: discount),
          ],
        ),
      ),
    );
  }
}
