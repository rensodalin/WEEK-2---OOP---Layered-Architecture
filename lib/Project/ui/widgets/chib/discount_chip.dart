import 'package:flutter/material.dart';
import '../../../model/discount.dart';

class DiscountChip extends StatelessWidget {
  final Discount discount;
  const DiscountChip({super.key, required this.discount});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text('${discount.percentage} % OFF'),
      backgroundColor: Color(0xFFEFEBE9),
    );
  }
}
