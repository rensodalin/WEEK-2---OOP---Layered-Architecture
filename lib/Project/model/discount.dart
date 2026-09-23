import 'order.dart';

/// Immutable Value Object representing a discount coupon with an optional minimum order spend threshold.
class Discount {
  final String code;
  final double percentage;
  final double minOrderAmount; 

  Discount({
    required this.code,
    required this.percentage,
    this.minOrderAmount = 0.0,
  }) {
    if (percentage < 0 || percentage > 100) {
      throw Exception('Discount percentage must be between 0 and 100');
    }
    if (minOrderAmount < 0) {
      throw Exception('Minimum order amount cannot be negative');
    }
  }
  void validateEligibility(Order order) {
    if (order.rawTotal < minOrderAmount) {
      throw Exception(
          'Order total does not meet the minimum requirement',
      );
    }
  }
}
