import 'package:test/test.dart';
import '../lib/model/discount.dart';
import '../lib/model/menu_item.dart';
import '../lib/service/restaurant_service.dart';

void main() {
  late RestaurantService service;

  setUp(() {
    // use set up because many test need the same data
    service = RestaurantService();

    // Seed test data
    service.registerCustomer(
      id: 'C01',
      name: 'Alice Johnson',
      phone: '012-345-678',
    );
    service.registerCustomer(
      id: 'C02',
      name: 'Bob Smith',
      phone: '098-765-432',
    );

    service.addTable(tableNumber: 1, capacity: 4);
    service.addTable(tableNumber: 2, capacity: 2);

    service.addMenuItem(
      MenuItem.beverage(id: 'M01', name: 'Iced Latte', price: 3.50),
    );
    service.addMenuItem(
      MenuItem.food(id: 'M02', name: 'Croissant', price: 2.50),
    );
    service.addMenuItem(
      MenuItem.food(id: 'M03', name: 'Club Sandwich', price: 6.00),
    );
  });

  group('RestaurantService - Business Operations & Validation', () {
    // -------------------------------------------------------------
    // Test Case 1: Valid End-to-End Order & Billing Flow
    // -------------------------------------------------------------
    test('opens order, adds items, computes total, and checks out successfully',
        () {
      // 1. Open order for 2 guests at Table 1
      service.openOrder(
        orderId: 'ORD-001',
        customerId: 'C01',
        tableNumber: 1,
        guestCount: 2,
      );

      final table = service.tables.firstWhere((t) => t.tableNumber == 1);
      expect(table.isOccupied, isTrue);

      // 2. Add 2 Lattes and 1 Sandwich
      service.addItemToOrder(
        orderId: 'ORD-001',
        menuItemId: 'M01',
        quantity: 2,
      ); // 2 * 3.50 = 7.00
      service.addItemToOrder(
        orderId: 'ORD-001',
        menuItemId: 'M03',
        quantity: 1,
      ); // 1 * 6.00 = 6.00

      final order = service.orders.firstWhere((o) => o.id == 'ORD-001');
      expect(order.items.length, 2);
      expect(order.rawTotal, 13.00);
      expect(order.totalAmount, 13.00);
      expect(order.isOpen, isTrue);

      // 3. Settle and checkout order
      final finalAmount = service.checkoutOrder(orderId: 'ORD-001');
      expect(finalAmount, 13.00);
      expect(order.isPaid, isTrue);
      expect(order.isOpen, isFalse);
      expect(table.isOccupied, isFalse); // Table must be freed
    });

    // -------------------------------------------------------------
    // Test Case 2: Business Rule - Table Seating Capacity
    // -------------------------------------------------------------
    test('throws exception when party size exceeds table capacity', () {
      // Table 2 capacity is 2, trying to seat 4 guests
      expect(
        () => service.openOrder(
          orderId: 'ORD-002',
          customerId: 'C01',
          tableNumber: 2,
          guestCount: 4,
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

    // -------------------------------------------------------------
    // Test Case 3: Business Rule - Double Seating on Occupied Table
    // -------------------------------------------------------------
    test(
        'throws exception when attempting to seat on an already occupied table',
        () {
      // Seat customer C01 at Table 1
      service.openOrder(
        orderId: 'ORD-003',
        customerId: 'C01',
        tableNumber: 1,
        guestCount: 2,
      );

      // Attempt to seat customer C02 at same Table 1
      expect(
        () => service.openOrder(
          orderId: 'ORD-004',
          customerId: 'C02',
          tableNumber: 1,
          guestCount: 2,
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

    // -------------------------------------------------------------
    // Test Case 4: Business Rule - Invalid Quantity & Unknown Menu Item
    // -------------------------------------------------------------
    test('throws exception for zero/negative quantity or unknown item', () {
      service.openOrder(
        orderId: 'ORD-005',
        customerId: 'C01',
        tableNumber: 1,
        guestCount: 1,
      );

      // 1. Zero quantity
      expect(
        () => service.addItemToOrder(
          orderId: 'ORD-005',
          menuItemId: 'M01',
          quantity: 0,
        ),
        throwsA(isA<Exception>()),
      );

      // 2. Negative quantity
      expect(
        () => service.addItemToOrder(
          orderId: 'ORD-005',
          menuItemId: 'M01',
          quantity: -3,
        ),
        throwsA(isA<Exception>()),
      );

      // 3. Unknown menu item
      expect(
        () => service.addItemToOrder(
          orderId: 'ORD-005',
          menuItemId: 'NON_EXISTENT',
          quantity: 1,
        ),
        throwsA(isA<Exception>()),
      );
    });

    // -------------------------------------------------------------
    // Test Case 5: Discount Calculation & Immutable Discount Object
    // -------------------------------------------------------------
    test('applies percentage discount correctly and rejects invalid discounts',
        () {
      service.openOrder(
        orderId: 'ORD-006',
        customerId: 'C01',
        tableNumber: 1,
        guestCount: 2,
      );

      // Order: 2 Croissants ($2.50 ea) + 1 Sandwich ($6.00) = $11.00
      service.addItemToOrder(
        orderId: 'ORD-006',
        menuItemId: 'M02',
        quantity: 2,
      );
      service.addItemToOrder(
        orderId: 'ORD-006',
        menuItemId: 'M03',
        quantity: 1,
      );

      // Apply 20% discount coupon: 11.00 - (11.00 * 0.20) = 8.80
      final promoDiscount = Discount(code: 'SAVE20', percentage: 20.0);
      service.applyDiscount(orderId: 'ORD-006', discount: promoDiscount);

      final order = service.orders.firstWhere((o) => o.id == 'ORD-006');
      expect(order.rawTotal, 11.00);
      expect(order.discountAmount, closeTo(2.20, 0.001));
      expect(order.totalAmount, closeTo(8.80, 0.001));

      // Boundary check: Discount percentage cannot be > 100 or < 0
      expect(
        () => Discount(code: 'INVALID', percentage: 150.0),
        throwsA(isA<Exception>()),
      );
      expect(
        () => Discount(code: 'NEGATIVE', percentage: -10.0),
        throwsA(isA<Exception>()),
      );
    });

    // -------------------------------------------------------------
    // Test Case 6: Order Cancellation & State Guarding
    // -------------------------------------------------------------
    test('cancelling order frees the table and prevents further modifications',
        () {
      service.openOrder(
        orderId: 'ORD-007',
        customerId: 'C02',
        tableNumber: 2,
        guestCount: 1,
      );

      final table = service.tables.firstWhere((t) => t.tableNumber == 2);
      expect(table.isOccupied, isTrue);

      // Cancel order
      service.cancelOrder(orderId: 'ORD-007');

      final order = service.orders.firstWhere((o) => o.id == 'ORD-007');
      expect(order.isCancelled, isTrue);
      expect(order.isOpen, isFalse);
      expect(table.isOccupied, isFalse); // Table freed

      // Cannot add items to a cancelled order
      expect(
        () => service.addItemToOrder(
          orderId: 'ORD-007',
          menuItemId: 'M01',
          quantity: 1,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
