import 'order.dart';

class RestaurantTable {
  final int tableNumber;
  final int capacity;
  Order? currentOrder;
  bool _isOccupied = false;

  RestaurantTable({
    required this.tableNumber,
    required this.capacity,
    this.currentOrder,
  }) : _isOccupied = currentOrder != null && currentOrder.isOpen;

  bool get isOccupied =>
      currentOrder != null ? currentOrder!.isOpen : _isOccupied;

  void occupy([Order? order]) {
    _isOccupied = true;
    currentOrder = order;
  }

  void release() {
    _isOccupied = false;
    currentOrder = null;
  }
}

