import 'discount.dart';
import 'order_item.dart';

class Order {
  final String id;
  final String customerId;
  final int tableNumber;
  final List<OrderItem> items = [];
  Discount? discount;
  bool _isPaid = false;
  bool _isCancelled = false;

  Order({
    required this.id,
    required this.customerId,
    required this.tableNumber,
  });

  bool get isPaid => _isPaid;
  bool get isCancelled => _isCancelled;
  bool get isOpen => !_isPaid && !_isCancelled;
  double get rawTotal {
    double total = 0.0;
    for (final item in items) {
      total += item.subtotal;
    }
    return total;
  }

  double get discountAmount {
    if (discount == null) return 0.0;
    return rawTotal * (discount!.percentage / 100.0);
  }

  double get totalAmount => rawTotal - discountAmount;

  void addItem(OrderItem item) {
    if (!isOpen) {
      throw Exception('Cannot add items to a closed or cancelled order');
    }
    items.add(item);
  }

  void applyDiscount(Discount discount) {
    if (!isOpen) {
      throw Exception('Cannot apply discount to a closed or cancelled order');
    }
    this.discount = discount;
  }

  void markPaid() {
    if (!isOpen) {
      throw Exception('Order is already paid or cancelled');
    }
    _isPaid = true;
  }

  void cancel() {
    if (_isPaid) {
      throw Exception('Cannot cancel a completed/paid order');
    }
    _isCancelled = true;
  }
}
