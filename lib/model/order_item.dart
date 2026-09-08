import 'menu_item.dart';

class OrderItem {
  final MenuItem menuItem;
  final int quantity;

  OrderItem({
    required this.menuItem,
    required this.quantity,
  }) {
    if (quantity <= 0) {
      throw Exception('Quantity must be greater than 0');
    }
  }

  // Computed property: subtotal for this item line
  double get subtotal => menuItem.price * quantity;
}
