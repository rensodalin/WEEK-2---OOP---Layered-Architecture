import 'discount.dart';
import 'order_item.dart';

enum OrderStatus {
  open,
  paid,
  cancelled,
}

class Order {
  final String id;
  final int tableNumber;
  final String waiterId;
  final int guestCount;
  final List<OrderItem> items = [];
  Discount? discount;
  OrderStatus _status = OrderStatus.open;

  Order({
    required this.id,
    required this.tableNumber,
    required this.waiterId,
    required this.guestCount,
    OrderStatus status = OrderStatus.open,
  }) : _status = status;

  OrderStatus get status => _status;

  bool get isOpen => _status == OrderStatus.open;
  bool get isPaid => _status == OrderStatus.paid;
  bool get isCancelled => _status == OrderStatus.cancelled;

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

    final index = items.indexWhere(
      (existing) => existing.menuItem.id == item.menuItem.id,
    );

    if (index != -1) {
      final existingItem = items[index];
      items[index] = OrderItem(
        menuItem: existingItem.menuItem,
        quantity: existingItem.quantity + item.quantity,
      );
    } else {
      items.add(item);
    }
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

  void increaseItemQuantity(OrderItem item) {
    if (!isOpen) {
      throw Exception('Cannot modify items in a closed or cancelled order');
    }
    item.increment();
  }

  void decreaseItemQuantity(OrderItem item) {
    if (!isOpen) {
      throw Exception('Cannot modify items in a closed or cancelled order');
    }
    if (item.quantity > 1) {
      item.decrement();
    } else {
      items.remove(item);
    }
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
    _status = OrderStatus.paid;
  }

  void cancel() {
    if (isPaid) {
      throw Exception('Cannot cancel a completed/paid order');
    }
    _status = OrderStatus.cancelled;
  }
}
