import 'discount.dart';
import 'order_item.dart';

class Order {
  final String id;
  final int tableNumber;
  final String waiterId;
  final int guestCount;
  final List<OrderItem> items = [];
  Discount? discount;
  bool _isPaid = false;
  bool _isCancelled = false;

  Order({
    required this.id,
    required this.tableNumber,
    required this.waiterId,
    required this.guestCount,
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

  void removeItem(String menuItemId) {
    if (!isOpen) {
      throw Exception('Cannot remove items from a closed or cancelled order ');
    }

    final item = items
        .where(
          (item) => item.menuItem.id == menuItemId,
        )
        .toList();

    if (item.isEmpty) {
      throw Exception('Menu item not found');
    }

    items.remove(item.first);
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
