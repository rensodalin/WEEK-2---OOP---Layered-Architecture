import 'menu_item.dart';

class OrderItem {
  final MenuItem menuItem;
  int quantity;

  OrderItem({
    required this.menuItem,
    required this.quantity,
  }) {
    if (quantity <= 0) {
      throw Exception('Quantity must be greater than 0');
    }
  }

  void increment() {
    quantity++;
  }

  void decrement() {
    if (quantity > 1) {
      quantity--;
    }
  }

  // Computed property: subtotal for this item line
  double get subtotal => menuItem.price * quantity;
}
