class Discount {
  final String code; // this is immutable value object
  final double percentage;

  Discount({
    required this.code,
    required this.percentage,
  }) {
    if (percentage < 0 || percentage > 100) {
      throw Exception('Discount percentage must be between 0 and 100');
    }
  }
}
