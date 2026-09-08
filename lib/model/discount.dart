/// Immutable Value Object representing a percentage discount coupon
class Discount {
  final String code;
  final double percentage; // e.g. 20.0 for 20%

  Discount({
    required this.code,
    required this.percentage,
  }) {
    if (percentage < 0 || percentage > 100) {
      throw Exception('Discount percentage must be between 0 and 100');
    }
  }
}
