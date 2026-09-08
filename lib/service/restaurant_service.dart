import '../model/customer.dart';
import '../model/discount.dart';
import '../model/menu_item.dart';
import '../model/order.dart';
import '../model/order_item.dart';
import '../model/restaurant_table.dart';

class RestaurantService {
  final List<Customer> customers = [];
  final List<RestaurantTable> tables = [];
  final List<MenuItem> menu = [];
  final List<Order> orders = [];

  // =============================================================
  // Setup & Registration
  // =============================================================

  void registerCustomer({
    required String id,
    required String name,
    required String phone,
  }) {
    if (_findCustomerOrNull(id) != null) {
      throw Exception('Customer with ID $id already exists');
    }
    customers.add(Customer(id: id, name: name, phone: phone));
  }

  void addTable({
    required int tableNumber,
    required int capacity,
  }) {
    if (_findTableOrNull(tableNumber) != null) {
      throw Exception('Table number $tableNumber already exists');
    }
    tables.add(RestaurantTable(tableNumber: tableNumber, capacity: capacity));
  }

  void addMenuItem(MenuItem item) {
    if (_findMenuItemOrNull(item.id) != null) {
      throw Exception('Menu item with ID ${item.id} already exists');
    }
    menu.add(item);
  }

  // =============================================================
  // Business Operation 1 (BO1): Open Table & Create Order
  // =============================================================

  void openOrder({
    required String orderId,
    required String customerId,
    required int tableNumber,
    required int guestCount,
  }) {
    if (_findOrderOrNull(orderId) != null) {
      throw Exception('Order $orderId already exists');
    }

    final customer = _findCustomerOrNull(
        customerId); // use final because we want to store customer we found in variable and use the result ;
    if (customer == null) {
      throw Exception('Customer $customerId not found');
    }

    final table = _findTableOrNull(tableNumber);
    if (table == null) {
      throw Exception('Table $tableNumber not found');
    }

    if (table.isOccupied) {
      throw Exception('Table $tableNumber is already occupied');
    }

    if (guestCount <= 0) {
      throw Exception('Guest count must be greater than 0');
    }

    if (guestCount > table.capacity) {
      throw Exception(
        'Guest count ($guestCount) exceeds table capacity (${table.capacity})',
      );
    }

    // Mark table as occupied
    table.occupy();

    // Create and record new order
    final order = Order(
      id: orderId,
      customerId: customerId,
      tableNumber: tableNumber,
    );
    orders.add(order);
  }

  // =============================================================
  // Business Operation 2 (BO2): Add Item to Order
  // =============================================================

  void addItemToOrder({
    required String orderId,
    required String menuItemId,
    required int quantity,
  }) {
    final order = _findOrderOrNull(orderId);
    if (order == null) {
      throw Exception('Order $orderId not found');
    }

    if (!order.isOpen) {
      throw Exception('Cannot add items to a closed or cancelled order');
    }

    final menuItem = _findMenuItemOrNull(menuItemId);
    if (menuItem == null) {
      throw Exception('Menu item $menuItemId not found');
    }

    if (quantity <= 0) {
      throw Exception('Quantity must be greater than 0');
    }

    final orderItem = OrderItem(menuItem: menuItem, quantity: quantity);
    order.addItem(orderItem);
  }

  // =============================================================
  // Business Operation 3 (BO3): Apply Promotional Discount
  // =============================================================

  void applyDiscount({
    required String orderId,
    required Discount discount,
  }) {
    final order = _findOrderOrNull(orderId);
    if (order == null) {
      throw Exception('Order $orderId not found');
    }

    if (!order.isOpen) {
      throw Exception('Cannot apply discount to a closed or cancelled order');
    }

    order.applyDiscount(discount);
  }

  // =============================================================
  // Business Operation 4 (BO4): Checkout & Settle Bill
  // =============================================================

  double checkoutOrder({required String orderId}) {
    final order = _findOrderOrNull(orderId);
    if (order == null) {
      throw Exception('Order $orderId not found');
    }

    if (!order.isOpen) {
      throw Exception('Order is already paid or cancelled');
    }

    if (order.items.isEmpty) {
      throw Exception('Cannot checkout an empty order');
    }

    final table = _findTableOrNull(order.tableNumber);
    if (table != null) {
      table.release();
    }

    order.markPaid();
    return order.totalAmount;
  }

  // =============================================================
  // Business Operation 5 (BO5): Cancel Order
  // =============================================================

  void cancelOrder({required String orderId}) {
    final order = _findOrderOrNull(orderId);
    if (order == null) {
      throw Exception('Order $orderId not found');
    }

    if (order.isPaid) {
      throw Exception('Cannot cancel a completed/paid order');
    }

    final table = _findTableOrNull(order.tableNumber);
    if (table != null) {
      table.release();
    }

    order.cancel();
  }

  // =============================================================
  // Lookup Queries
  // =============================================================

  // Order? findActiveOrderByTable(int tableNumber) {
  //   for (final order in orders) {
  //     if (order.tableNumber == tableNumber && order.isOpen) {
  //       return order;
  //     }
  //   }
  //   return null;
  // }

  // =============================================================
  // Private Helper Lookup Methods
  // =============================================================

  Customer? _findCustomerOrNull(String customerId) {
    for (final c in customers) {
      if (c.id == customerId) return c;
    }
    return null;
  }

  RestaurantTable? _findTableOrNull(int tableNumber) {
    for (final t in tables) {
      if (t.tableNumber == tableNumber) return t;
    }
    return null;
  }

  MenuItem? _findMenuItemOrNull(String menuItemId) {
    for (final m in menu) {
      if (m.id == menuItemId) return m;
    }
    return null;
  }

  Order? _findOrderOrNull(String orderId) {
    for (final o in orders) {
      if (o.id == orderId) return o;
    }
    return null;
  }
}
