import 'package:test/test.dart';
import '../lib/Project/model/discount.dart';
import '../lib/Project/model/menu_item.dart';
import '../lib/Project/model/staff.dart';
import '../lib/Project/service/restaurant_service.dart';

void main() {
  late RestaurantService service;

  setUp(() {
    service = RestaurantService();

    // Register Staff Members with distinct roles
    service.registerStaff(
      id: 'W01',
      name: 'John Waiter',
      role: StaffRole.waiter,
    );
    service.registerStaff(
      id: 'K01',
      name: 'Sarah Cashier',
      role: StaffRole.cashier,
    );
    service.registerStaff(
      id: 'MGR01',
      name: 'Mike Manager',
      role: StaffRole.manager,
    );

    service.addTable(managerId: 'MGR01', tableNumber: 1, capacity: 4);
    service.addTable(managerId: 'MGR01', tableNumber: 2, capacity: 2);

    service.addMenuItem(
      managerId: 'MGR01',
      item: MenuItem.beverage(id: 'M01', name: 'Iced Latte', price: 3.50),
    );
    service.addMenuItem(
      managerId: 'MGR01',
      item: MenuItem.food(id: 'M02', name: 'Croissant', price: 2.50),
    );
    service.addMenuItem(
      managerId: 'MGR01',
      item: MenuItem.food(id: 'M03', name: 'Club Sandwich', price: 6.00),
    );
  });

  group('RestaurantService', () {
    // Test 1: Valid End-to-End Order
    test('opens order, adds items, computes total, and checks out successfully',
        () {
      // 1. Open order for 2 guests at Table 1 by Waiter W01
      service.openOrder(
        orderId: 'ORD-001',
        tableNumber: 1,
        guestCount: 2,
        waiterId: 'W01',
      );

      final table = service.tables.firstWhere((t) => t.tableNumber == 1);
      expect(table.isOccupied, isTrue);
      expect(service.orders.first.guestCount, equals(2));

      service.addItemToOrder(
        waiterId: 'W01',
        orderId: 'ORD-001',
        menuItemId: 'M01',
        quantity: 2,
      );
      service.addItemToOrder(
        waiterId: 'W01',
        orderId: 'ORD-001',
        menuItemId: 'M03',
        quantity: 1,
      );

      final order = service.orders.firstWhere((o) => o.id == 'ORD-001');
      expect(order.items.length, 2);
      expect(order.waiterId, 'W01');
      expect(order.rawTotal, 13.00);
      expect(order.totalAmount, 13.00);
      expect(order.isOpen, isTrue);

      // Settle bill through Cashier K01
      final finalAmount = service.checkoutOrder(
        orderId: 'ORD-001',
        cashierId: 'K01',
      );
      expect(finalAmount, 13.00);
      expect(order.isPaid, isTrue);
      expect(order.isOpen, isFalse);
      expect(table.isOccupied, isFalse);
    });

    // Test 2: Table Seating Capacity
    test('throws exception when party size exceeds table capacity', () {
      expect(
        () => service.openOrder(
          orderId: 'ORD-002',
          tableNumber: 2,
          guestCount: 4,
          waiterId: 'W01',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('exceeds table capacity'),
          ),
        ),
      );

      final table = service.tables.firstWhere((t) => t.tableNumber == 2);
      expect(table.isOccupied, isFalse);
    });

    // Test 3: Double Seating on Occupied Table
    test(
        'throws exception when attempting to seat on an already occupied table',
        () {
      service.openOrder(
        orderId: 'ORD-003',
        tableNumber: 1,
        guestCount: 2,
        waiterId: 'W01',
      );

      expect(
        () => service.openOrder(
          orderId: 'ORD-004',
          tableNumber: 1,
          guestCount: 2,
          waiterId: 'W01',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('already occupied'),
          ),
        ),
      );
    });

    // Test 4: Invalid Quantity & Unknown Menu Item
    test('throws exception for zero/negative quantity or unknown item', () {
      service.openOrder(
        orderId: 'ORD-005',
        tableNumber: 1,
        guestCount: 1,
        waiterId: 'W01',
      );
      expect(
        () => service.addItemToOrder(
          waiterId: 'W01',
          orderId: 'ORD-005',
          menuItemId: 'M01',
          quantity: 0,
        ),
        throwsA(isA<Exception>()),
      );

      expect(
        () => service.addItemToOrder(
          waiterId: 'W01',
          orderId: 'ORD-005',
          menuItemId: 'M01',
          quantity: -3,
        ),
        throwsA(isA<Exception>()),
      );
      expect(
        () => service.addItemToOrder(
          waiterId: 'W01',
          orderId: 'ORD-005',
          menuItemId: 'NON_EXISTENT',
          quantity: 1,
        ),
        throwsA(isA<Exception>()),
      );
    });

    // Test 5: Discount Calculation
    test('applies percentage discount correctly and rejects invalid discounts',
        () {
      service.openOrder(
        orderId: 'ORD-006',
        tableNumber: 1,
        guestCount: 2,
        waiterId: 'W01',
      );
      service.addItemToOrder(
        waiterId: 'W01',
        orderId: 'ORD-006',
        menuItemId: 'M02',
        quantity: 2,
      );
      service.addItemToOrder(
        waiterId: 'W01',
        orderId: 'ORD-006',
        menuItemId: 'M03',
        quantity: 1,
      );

      final promoDiscount = Discount(code: 'SAVE20', percentage: 20.0);
      service.applyDiscount(
        cashierId: 'K01',
        orderId: 'ORD-006',
        discount: promoDiscount,
      );

      final order = service.orders.firstWhere((o) => o.id == 'ORD-006');
      expect(order.rawTotal, 11.00);
      expect(order.discountAmount, closeTo(2.20, 0.001));
      expect(order.totalAmount, closeTo(8.80, 0.001));

      expect(
        () => Discount(code: 'INVALID', percentage: 150.0),
        throwsA(isA<Exception>()),
      );
      expect(
        () => Discount(code: 'NEGATIVE', percentage: -10.0),
        throwsA(isA<Exception>()),
      );
    });

    // Test 6: Order Cancellation
    test('cancelling order frees the table and prevents further modifications',
        () {
      service.openOrder(
        orderId: 'ORD-007',
        tableNumber: 2,
        guestCount: 1,
        waiterId: 'W01',
      );

      final table = service.tables.firstWhere((t) => t.tableNumber == 2);
      expect(table.isOccupied, isTrue);

      service.cancelOrder(
        waiterId: 'W01',
        orderId: 'ORD-007',
      );

      final order = service.orders.firstWhere((o) => o.id == 'ORD-007');
      expect(order.isCancelled, isTrue);
      expect(order.isOpen, isFalse);
      expect(table.isOccupied, isFalse); // Table freed
      expect(
        () => service.addItemToOrder(
          waiterId: 'W01',
          orderId: 'ORD-007',
          menuItemId: 'M01',
          quantity: 1,
        ),
        throwsA(isA<Exception>()),
      );
    });

    // Test 7: Role-Based Access Control (RBAC) Permissions
    test('enforces role permissions: cashiers cannot open orders, waiters cannot checkout',
        () {
      // 1. Cashier attempts to open an order -> rejected
      expect(
        () => service.openOrder(
          orderId: 'ORD-008',
          tableNumber: 1,
          guestCount: 2,
          waiterId: 'K01', // Cashier
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not authorized to open orders'),
          ),
        ),
      );

      // 2. Non-existent staff member -> rejected
      expect(
        () => service.openOrder(
          orderId: 'ORD-008',
          tableNumber: 1,
          guestCount: 2,
          waiterId: 'UNKNOWN_STAFF',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not found'),
          ),
        ),
      );

      // 3. Open valid order by waiter
      service.openOrder(
        orderId: 'ORD-008',
        tableNumber: 1,
        guestCount: 2,
        waiterId: 'W01',
      );
      service.addItemToOrder(
        waiterId: 'W01',
        orderId: 'ORD-008',
        menuItemId: 'M01',
        quantity: 1,
      );

      // Cashier attempts to add item -> rejected
      expect(
        () => service.addItemToOrder(
          waiterId: 'K01', // Cashier
          orderId: 'ORD-008',
          menuItemId: 'M01',
          quantity: 1,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not authorized to add items to orders'),
          ),
        ),
      );

      // Waiter attempts to apply discount -> rejected
      expect(
        () => service.applyDiscount(
          cashierId: 'W01', // Waiter
          orderId: 'ORD-008',
          discount: Discount(code: 'TEST', percentage: 10),
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not authorized to apply discounts'),
          ),
        ),
      );

      // Cashier applies discount -> allowed
      service.applyDiscount(
        cashierId: 'K01', // Cashier
        orderId: 'ORD-008',
        discount: Discount(code: 'TEST', percentage: 10),
      );

      // Cashier attempts to cancel order -> rejected
      expect(
        () => service.cancelOrder(
          waiterId: 'K01', // Cashier
          orderId: 'ORD-008',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not authorized to cancel orders'),
          ),
        ),
      );

      // 4. Waiter attempts to checkout -> rejected
      expect(
        () => service.checkoutOrder(
          orderId: 'ORD-008',
          cashierId: 'W01', // Waiter
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not authorized to checkout orders'),
          ),
        ),
      );

      // 5. Manager can checkout (Manager has authorization)
      final total = service.checkoutOrder(
        orderId: 'ORD-008',
        cashierId: 'MGR01', // Manager
      );
      expect(total, 3.15); // $3.50 minus 10% discount ($0.35) = $3.15
    });

    // Test 8: Minimum Order Spend Discount Threshold (e.g. Spend $50, get 10% off)
    test('enforces minimum spend requirement for spend-threshold discounts',
        () {
      // 1. Open order with $13.00 total (2 lattes $7.00 + 1 sandwich $6.00)
      service.openOrder(
        orderId: 'ORD-009',
        tableNumber: 1,
        guestCount: 2,
        waiterId: 'W01',
      );
      service.addItemToOrder(
        waiterId: 'W01',
        orderId: 'ORD-009',
        menuItemId: 'M01',
        quantity: 2,
      );
      service.addItemToOrder(
        waiterId: 'W01',
        orderId: 'ORD-009',
        menuItemId: 'M03',
        quantity: 1,
      );

      final spend50Discount = Discount(
        code: 'SPEND50',
        percentage: 10.0,
        minOrderAmount: 50.0,
      );

      // Order total is only $13.00, does not meet $50.00 requirement -> rejected
      expect(
        () => service.applyDiscount(
          cashierId: 'K01',
          orderId: 'ORD-009',
          discount: spend50Discount,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('does not meet the minimum requirement'),
          ),
        ),
      );

      // 2. Add more items to exceed $50.00 (7 more sandwiches = 7 * $6.00 = $42.00, total $55.00)
      service.addItemToOrder(
        waiterId: 'W01',
        orderId: 'ORD-009',
        menuItemId: 'M03',
        quantity: 7,
      );

      final order = service.orders.firstWhere((o) => o.id == 'ORD-009');
      expect(order.rawTotal, 55.00);

      // Now order total is $55.00 >= $50.00 -> cashier applies discount successfully!
      service.applyDiscount(
        cashierId: 'K01',
        orderId: 'ORD-009',
        discount: spend50Discount,
      );

      expect(order.discount?.code, 'SPEND50');
      expect(order.discountAmount, closeTo(5.50, 0.001)); // 10% of $55 = $5.50
      expect(order.totalAmount, closeTo(49.50, 0.001));
    });

    // Test 9: Filter Available Tables for Waiters
    test('waiter can filter available tables with party size and authorization checks', () {
      // Setup: Table 1 (cap 4) and Table 2 (cap 2) initially both unoccupied
      // Add a third table: Table 3 (cap 6)
      service.addTable(managerId: 'MGR01', tableNumber: 3, capacity: 6);

      // 1. Waiter W01 queries all available tables -> all 3 tables returned
      final allAvailable = service.getAvailableTables(staffId: 'W01');
      expect(allAvailable.length, 3);

      // 2. Waiter W01 queries tables for a party of 3 -> Table 1 (cap 4) and Table 3 (cap 6), Table 2 (cap 2) excluded
      final tablesFor3 = service.getAvailableTables(
        staffId: 'W01',
        guestCount: 3,
      );
      expect(tablesFor3.length, 2);
      expect(tablesFor3.map((t) => t.tableNumber), containsAll([1, 3]));
      expect(tablesFor3.map((t) => t.tableNumber), isNot(contains(2)));

      // 3. Occupy Table 1
      service.openOrder(
        orderId: 'ORD-010',
        tableNumber: 1,
        guestCount: 2,
        waiterId: 'W01',
      );

      // Occupied Table 1 should now be excluded from available tables
      final availableAfterSeat = service.getAvailableTables(staffId: 'W01');
      expect(availableAfterSeat.length, 2);
      expect(availableAfterSeat.map((t) => t.tableNumber), containsAll([2, 3]));
      expect(availableAfterSeat.map((t) => t.tableNumber), isNot(contains(1)));

      // 4. Unauthorized staff (Cashier K01) is rejected
      expect(
        () => service.getAvailableTables(staffId: 'K01'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not authorized to query available tables'),
          ),
        ),
      );

      // 5. Non-existent staff is rejected
      expect(
        () => service.getAvailableTables(staffId: 'UNKNOWN'),
        throwsA(isA<Exception>()),
      );

      // 6. Invalid guest count (<= 0) is rejected
      expect(
        () => service.getAvailableTables(staffId: 'W01', guestCount: 0),
        throwsA(isA<Exception>()),
      );
    });

    // Test 10: Manager Administration (Tables, Menu Items, and Discounts)
    test('manager can manage tables, menu items, and discounts; unauthorized roles are rejected', () {
      // 1. Tables: Waiter cannot add table
      expect(
        () => service.addTable(managerId: 'W01', tableNumber: 10, capacity: 4),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not authorized to add tables'),
          ),
        ),
      );

      // Manager can add table
      service.addTable(managerId: 'MGR01', tableNumber: 10, capacity: 4);
      expect(service.tables.any((t) => t.tableNumber == 10), isTrue);

      // 2. Menu Items: Cashier cannot add menu items
      expect(
        () => service.addMenuItem(
          managerId: 'K01',
          item: MenuItem.food(id: 'M99', name: 'Steak', price: 25.00),
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not authorized to add menu items'),
          ),
        ),
      );

      // Manager can add menu item
      service.addMenuItem(
        managerId: 'MGR01',
        item: MenuItem.food(id: 'M99', name: 'Steak', price: 25.00),
      );
      expect(service.menu.any((m) => m.id == 'M99'), isTrue);

      // 3. Discounts: Waiter cannot manage discounts
      final promoDiscount = Discount(code: 'PROMO15', percentage: 15.0);
      expect(
        () => service.addDiscount(managerId: 'W01', discount: promoDiscount),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not authorized to manage discounts'),
          ),
        ),
      );

      // Manager can add discount
      service.addDiscount(managerId: 'MGR01', discount: promoDiscount);
      expect(service.discounts.any((d) => d.code == 'PROMO15'), isTrue);

      // Duplicate discount code rejected
      expect(
        () => service.addDiscount(managerId: 'MGR01', discount: promoDiscount),
        throwsA(isA<Exception>()),
      );

      // Apply registered discount by code to an open order
      service.openOrder(
        orderId: 'ORD-PROMO',
        tableNumber: 10,
        guestCount: 2,
        waiterId: 'W01',
      );
      service.addItemToOrder(
        waiterId: 'W01',
        orderId: 'ORD-PROMO',
        menuItemId: 'M99',
        quantity: 2, // 2 * $25 = $50
      );
      // Cashier applies registered discount to an open order before checkout
      service.applyDiscount(
        cashierId: 'K01',
        orderId: 'ORD-PROMO',
        discount: promoDiscount,
      );

      final promoOrder = service.orders.firstWhere((o) => o.id == 'ORD-PROMO');
      expect(promoOrder.discount?.code, 'PROMO15');
      expect(promoOrder.discountAmount, 7.50); // 15% of $50
      expect(promoOrder.totalAmount, 42.50);

      // Cashier settles bill at checkout
      final settledAmount = service.checkoutOrder(
        orderId: 'ORD-PROMO',
        cashierId: 'K01',
      );
      expect(settledAmount, 42.50);

      // Manager can remove discount
      service.removeDiscount(managerId: 'MGR01', code: 'PROMO15');
      expect(service.discounts.any((d) => d.code == 'PROMO15'), isFalse);

      // Non-manager cannot remove discount
      expect(
        () => service.removeDiscount(managerId: 'W01', code: 'PROMO15'),
        throwsA(isA<Exception>()),
      );
    });

    // Test 11: Real-Life Cafe Workflow (Manager sets SAVE20, Waiter takes order, Cashier applies at checkout)
    test('cafe workflow: manager creates SAVE20, waiter takes order, cashier checks and applies at checkout', () {
      // 1. Manager Mike creates SAVE20: 20% discount with $50 min spend
      final save20 = Discount(
        code: 'SAVE20',
        percentage: 20.0,
        minOrderAmount: 50.0,
      );
      service.addDiscount(managerId: 'MGR01', discount: save20);

      // 2. Waiter John opens order for Table 1 and adds items
      service.openOrder(
        orderId: 'ORD-CAFE',
        tableNumber: 1,
        guestCount: 2,
        waiterId: 'W01',
      );
      service.addItemToOrder(
        waiterId: 'W01',
        orderId: 'ORD-CAFE',
        menuItemId: 'M03', // Club Sandwich $6.00
        quantity: 10,      // 10 * $6.00 = $60.00
      );

      // 3. Waiter cannot apply the promotion
      expect(
        () => service.applyDiscount(
          cashierId: 'W01',
          orderId: 'ORD-CAFE',
          discount: save20,
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not authorized to apply discounts'),
          ),
        ),
      );

      // 4. Cashier Sarah checks out order ORD-CAFE, applies SAVE20 promo at checkout
      final table = service.tables.firstWhere((t) => t.tableNumber == 1);
      expect(table.isOccupied, isTrue);

      final totalPaid = service.checkoutOrder(
        orderId: 'ORD-CAFE',
        cashierId: 'K01',
        discountCode: 'SAVE20',
      );

      // Raw $60.00 - 20% ($12.00) = $48.00 final bill
      expect(totalPaid, 48.00);

      final order = service.orders.firstWhere((o) => o.id == 'ORD-CAFE');
      expect(order.isPaid, isTrue);
      expect(order.discount?.code, 'SAVE20');
      expect(table.isOccupied, isFalse); // Table freed after payment
    });

    // Tests for removeItemFromOrder
    test('removes item from open order and updates totals', () {
      service.openOrder(
        orderId: 'ORD-REM-1',
        tableNumber: 1,
        guestCount: 2,
        waiterId: 'W01',
      );
      service.addItemToOrder(
        waiterId: 'W01',
        orderId: 'ORD-REM-1',
        menuItemId: 'M01',
        quantity: 2,
      );
      service.addItemToOrder(
        waiterId: 'W01',
        orderId: 'ORD-REM-1',
        menuItemId: 'M02',
        quantity: 1,
      );

      final order = service.orders.firstWhere((o) => o.id == 'ORD-REM-1');
      expect(order.items.length, 2);
      expect(order.rawTotal, 9.50); // (3.50 * 2) + 2.50

      service.removeItemFromOrder(
        waiterId: 'W01',
        orderId: 'ORD-REM-1',
        menuItemId: 'M02',
      );

      expect(order.items.length, 1);
      expect(order.items.first.menuItem.id, 'M01');
      expect(order.rawTotal, 7.00);
    });

    test('throws exception when unauthorized staff attempts to remove item', () {
      service.openOrder(
        orderId: 'ORD-REM-2',
        tableNumber: 1,
        guestCount: 2,
        waiterId: 'W01',
      );
      service.addItemToOrder(
        waiterId: 'W01',
        orderId: 'ORD-REM-2',
        menuItemId: 'M01',
        quantity: 1,
      );

      expect(
        () => service.removeItemFromOrder(
          waiterId: 'K01', // Cashier
          orderId: 'ORD-REM-2',
          menuItemId: 'M01',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not authorized to remove items'),
          ),
        ),
      );
    });

    test('throws exception when removing item that is not in the order', () {
      service.openOrder(
        orderId: 'ORD-REM-3',
        tableNumber: 1,
        guestCount: 2,
        waiterId: 'W01',
      );

      expect(
        () => service.removeItemFromOrder(
          waiterId: 'W01',
          orderId: 'ORD-REM-3',
          menuItemId: 'M01',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('not found'),
          ),
        ),
      );
    });

    test('throws exception when removing item from a paid order', () {
      service.openOrder(
        orderId: 'ORD-REM-4',
        tableNumber: 1,
        guestCount: 2,
        waiterId: 'W01',
      );
      service.addItemToOrder(
        waiterId: 'W01',
        orderId: 'ORD-REM-4',
        menuItemId: 'M01',
        quantity: 1,
      );
      service.checkoutOrder(orderId: 'ORD-REM-4', cashierId: 'K01');

      expect(
        () => service.removeItemFromOrder(
          waiterId: 'W01',
          orderId: 'ORD-REM-4',
          menuItemId: 'M01',
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Cannot remove items from a closed or cancelled order'),
          ),
        ),
      );
    });

    test('manager can edit and delete menu items', () {
      // Edit price and name
      service.editMenuItem(
        managerId: 'MGR01',
        menuItemId: 'M01',
        newName: 'Iced Vanilla Latte',
        newPrice: 4.00,
      );

      final edited = service.menu.firstWhere((m) => m.id == 'M01');
      expect(edited.name, 'Iced Vanilla Latte');
      expect(edited.price, 4.00);

      // Delete item
      service.deleteMenuItem(
        managerId: 'MGR01',
        menuItemId: 'M01',
      );

      final exists = service.menu.any((m) => m.id == 'M01');
      expect(exists, isFalse);
    });
  });
}
