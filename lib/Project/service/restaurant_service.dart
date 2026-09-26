import '../model/discount.dart';
import '../model/menu_item.dart';
import '../model/order.dart';
import '../model/order_item.dart';
import '../model/restaurant_table.dart';
import '../model/staff.dart';

class RestaurantService {
  final List<Staff> staffMembers = [];
  final List<RestaurantTable> tables = [];
  final List<MenuItem> menu = [];
  final List<Order> orders = [];
  final List<Discount> discounts = [];

  //Register staf // abit confusing
  void registerStaff({
    required String id,
    required String name,
    required StaffRole role,
  }) {
    if (_findStaffOrNull(id) != null) {
      throw Exception('Staff with ID $id already exists');
    }
    staffMembers.add(Staff(id: id, name: name, role: role));
  }

  void addTable({
    required String managerId,
    required int tableNumber,
    required int capacity,
  }) {
    final manager = _findStaffOrNull(managerId);
    if (manager == null) {
      throw Exception('Staff member $managerId not found');
    }
    if (!manager.isManager) {
      throw Exception(
          'Staff member $managerId is not authorized to add tables');
    }
    if (_findTableOrNull(tableNumber) != null) {
      throw Exception('Table number $tableNumber already exists');
    }
    tables.add(RestaurantTable(tableNumber: tableNumber, capacity: capacity));
  }

  void addMenuItem({
    required String managerId,
    required MenuItem item,
  }) {
    final manager = _findStaffOrNull(managerId);
    if (manager == null) {
      throw Exception('Staff member $managerId not found');
    }
    if (!manager.isManager) {
      throw Exception(
          'Staff member $managerId is not authorized to add menu items');
    }
    if (_findMenuItemOrNull(item.id) != null) {
      throw Exception('Menu item with ID ${item.id} already exists');
    }
    menu.add(item);
  }

  void editMenuItem({
    required String managerId,
    required String menuItemId,
    String? newName,
    double? newPrice,
  }) {
    final manager = _findStaffOrNull(managerId);

    if (manager == null) {
      throw Exception('Staff member $managerId not found');
    }

    if (!manager.isManager) {
      throw Exception(
        'Staff member $managerId is not authorized to edit menu items',
      );
    }

    final item = _findMenuItemOrNull(menuItemId);

    if (item == null) {
      throw Exception('Menu item $menuItemId not found');
    }

    if (newPrice != null && newPrice < 0) {
      throw Exception('Price cannot be negative');
    }

    item.name = newName ??
        item.name; // if null use value on right otherwise use on left
    item.price = newPrice ?? item.price;
  }

  void deleteMenuItem({
    required String managerId,
    required String menuItemId,
  }) {
    final manager = _findStaffOrNull(managerId);
    if (manager == null) {
      throw Exception('Staff member $managerId not found');
    }
    if (!manager.isManager) {
      throw Exception(
          'Staff member $managerId is not authorized to delete menu items');
    }
    final item = _findMenuItemOrNull(menuItemId);
    if (item == null) {
      throw Exception('Menu item $menuItemId not found');
    }
    menu.remove(item);
  }

  void addDiscount({
    required String managerId,
    required Discount discount,
  }) {
    final manager = _findStaffOrNull(managerId);
    if (manager == null) {
      throw Exception('Staff member $managerId not found');
    }
    if (!manager.isManager) {
      throw Exception(
          'Staff member $managerId is not authorized to manage discounts');
    }
    if (_findDiscountOrNull(discount.code) != null) {
      throw Exception('Discount with code ${discount.code} already exists');
    }
    discounts.add(discount);
  }

  void removeDiscount({
    required String managerId,
    required String code,
  }) {
    final manager = _findStaffOrNull(managerId);
    if (manager == null) {
      throw Exception('Staff member $managerId not found');
    }
    if (!manager.isManager) {
      throw Exception(
          'Staff member $managerId is not authorized to manage discounts');
    }
    final discount = _findDiscountOrNull(code);
    if (discount == null) {
      throw Exception('Discount with code $code not found');
    }
    discounts.remove(discount);
  }

  List<RestaurantTable> getAvailableTables({
    String? staffId,
    int? guestCount,
  }) {
    if (staffId != null) {
      final staff = _findStaffOrNull(staffId);

      if (staff == null) {
        throw Exception('Staff member $staffId not found');
      }

      if (!staff.isWaiter && !staff.isManager) {
        throw Exception(
          'Staff member $staffId is not authorized to query available tables',
        );
      }
    }

    if (guestCount != null && guestCount <= 0) {
      throw Exception('Guest count must be greater than 0');
    }

    return tables.where((table) {
      if (table.isOccupied) return false;

      if (guestCount != null && table.capacity < guestCount) {
        return false;
      }

      return true;
    }).toList();
  }

  //  Open Table & Create Order

  void openOrder({
    required String orderId,
    required int tableNumber,
    required int guestCount,
    required String waiterId,
  }) {
    if (_findOrderOrNull(orderId) != null) {
      throw Exception('Order $orderId already exists');
    }

    final waiter = _findStaffOrNull(waiterId);
    if (waiter == null) {
      throw Exception('Staff member $waiterId not found');
    }
    if (!waiter.isWaiter && !waiter.isManager) {
      throw Exception(
          'Staff member $waiterId is not authorized to open orders');
    }

    final table = _findTableOrNull(tableNumber);
    if (table == null) {
      throw Exception('Table $tableNumber not found');
    }

    if (table.isOccupied) {
      throw Exception('Table $tableNumber is already occupied');
    }

    if (guestCount <= 0) {
      // guest count againt table capacity
      throw Exception('Guest count must be greater than 0');
    }

    if (guestCount > table.capacity) {
      // table capcity
      throw Exception(
        'Guest count ($guestCount) exceeds table capacity (${table.capacity})',
      );
    }
    table.occupy();

    // Create and record new order
    final order = Order(
      id: orderId,
      tableNumber: tableNumber,
      waiterId: waiterId,
      guestCount: guestCount,
    );
    orders.add(order);
  }
  // Add Item to Order

  void addItemToOrder({
    required String waiterId,
    required String orderId,
    required String menuItemId,
    required int quantity,
  }) {
    final waiter = _findStaffOrNull(waiterId);
    if (waiter == null) {
      throw Exception('Staff member $waiterId not found');
    }
    if (!waiter.isWaiter && !waiter.isManager) {
      throw Exception(
          'Staff member $waiterId is not authorized to add items to orders');
    }

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

  // Remove Item from Order
  void removeItemFromOrder({
    required String waiterId,
    required String orderId,
    required String menuItemId,
  }) {
    final waiter = _findStaffOrNull(waiterId);
    if (waiter == null) {
      throw Exception('Staff member $waiterId not found');
    }
    if (!waiter.isWaiter && !waiter.isManager) {
      throw Exception(
          'Staff member $waiterId is not authorized to remove items from orders');
    }

    final order = _findOrderOrNull(orderId);
    if (order == null) {
      throw Exception('Order $orderId not found');
    }

    order.removeItem(menuItemId);
  }

  //  Apply Discount

  void applyDiscount({
    required String cashierId,
    required String orderId,
    required Discount discount,
  }) {
    final cashier = _findStaffOrNull(cashierId);
    if (cashier == null) {
      throw Exception('Staff member $cashierId not found');
    }
    if (!cashier.isCashier && !cashier.isManager) {
      throw Exception(
          'Staff member $cashierId is not authorized to apply discounts');
    }

    final order = _findOrderOrNull(orderId);
    if (order == null) {
      throw Exception('Order $orderId not found');
    }

    if (!order.isOpen) {
      throw Exception('Cannot apply discount to a closed or cancelled order');
    }

    discount.validateEligibility(order);

    order.applyDiscount(discount);
  }

  // Checkout
  double checkoutOrder({
    required String orderId,
    required String cashierId,
    String? discountCode,
  }) {
    final order = _findOrderOrNull(orderId);
    if (order == null) {
      throw Exception('Order $orderId not found');
    }

    final cashier = _findStaffOrNull(cashierId);
    if (cashier == null) {
      throw Exception('Staff member $cashierId not found');
    }
    if (!cashier.isCashier && !cashier.isManager) {
      throw Exception(
          'Staff member $cashierId is not authorized to checkout orders');
    }

    if (!order.isOpen) {
      throw Exception('Order is already paid or cancelled');
    }

    if (order.items.isEmpty) {
      throw Exception('Cannot checkout an empty order');
    }

    if (discountCode != null) {
      final discount = _findDiscountOrNull(discountCode);
      if (discount == null) {
        throw Exception('Discount with code $discountCode not found');
      }
      applyDiscount(
        cashierId: cashierId,
        orderId: orderId,
        discount: discount,
      );
    }

    final table = _findTableOrNull(order.tableNumber);
    if (table != null) {
      table.release();
    }

    order.markPaid();
    return order.totalAmount;
  }

  // Cancel Order

  void cancelOrder({
    required String waiterId,
    required String orderId,
  }) {
    final waiter = _findStaffOrNull(waiterId);
    if (waiter == null) {
      throw Exception('Staff member $waiterId not found');
    }
    if (!waiter.isWaiter && !waiter.isManager) {
      throw Exception(
          'Staff member $waiterId is not authorized to cancel orders');
    }

    final order = _findOrderOrNull(orderId);
    if (order == null) {
      throw Exception('Order $orderId not found');
    }

    if (order.isPaid) {
      throw Exception('Cannot cancel a completed/paid order');
    }

    if (order.items.isNotEmpty) {
      throw Exception('Cannot cancel an order that contains items');
    }

    final table = _findTableOrNull(order.tableNumber);
    if (table != null) {
      table.release();
    }

    order.cancel();
  }

  // helper method

  Staff? _findStaffOrNull(String staffId) {
    for (final s in staffMembers) {
      if (s.id == staffId) return s;
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

  Discount? _findDiscountOrNull(String code) {
    for (final d in discounts) {
      if (d.code == code) return d;
    }
    return null;
  }
}
