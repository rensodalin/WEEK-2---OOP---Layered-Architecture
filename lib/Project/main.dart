import 'package:flutter/material.dart';
import 'package:my_app/Project/ui/screens/add_menu_item_to_order_form.dart';
import 'model/discount.dart';
import 'model/menu_item.dart';
import 'model/staff.dart';
import 'service/restaurant_service.dart';
import 'ui/screens/table_detail_screen.dart';
import 'ui/screens/restaurant_home_screen.dart';

void main() {
  final service = RestaurantService();
  service.registerStaff(
    id: 'MGR01',
    name: 'Mike Manager',
    role: StaffRole.manager,
  );
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
  service.addTable(managerId: 'MGR01', tableNumber: 1, capacity: 4);
  service.addTable(managerId: 'MGR01', tableNumber: 2, capacity: 2);
  service.addTable(managerId: 'MGR01', tableNumber: 3, capacity: 6);
  service.addTable(managerId: 'MGR01', tableNumber: 4, capacity: 4);
  service.addMenuItem(
    managerId: 'MGR01',
    item: MenuItem.beverage(id: 'M01', name: 'Iced Caramel Latte', price: 4.50),
  );
  service.addMenuItem(
    managerId: 'MGR01',
    item: MenuItem.beverage(id: 'M02', name: 'Espresso', price: 3.00),
  );
  service.addMenuItem(
    managerId: 'MGR01',
    item: MenuItem.food(id: 'M03', name: 'Butter Croissant', price: 3.50),
  );
  service.addMenuItem(
    managerId: 'MGR01',
    item: MenuItem.food(id: 'M04', name: 'Club Sandwich', price: 7.50),
  );
  service.addMenuItem(
    managerId: 'MGR01',
    item: MenuItem.food(id: 'M05', name: 'Avocado Toast', price: 6.50),
  );

  service.addDiscount(
    managerId: 'MGR01',
    discount: Discount(code: 'SAVE20', percentage: 20.0, minOrderAmount: 25.0),
  );
  service.addDiscount(
    managerId: 'MGR01',
    discount:
        Discount(code: 'WELCOME10', percentage: 10.0, minOrderAmount: 0.0),
  );

  service.openOrder(
    orderId: 'ORD-001',
    tableNumber: 1,
    guestCount: 3,
    waiterId: 'W01',
  );
  service.addItemToOrder(
    waiterId: 'W01',
    orderId: 'ORD-001',
    menuItemId: 'M02',
    quantity: 2,
  );
  service.addItemToOrder(
    waiterId: 'W01',
    orderId: 'ORD-001',
    menuItemId: 'M04',
    quantity: 2,
  );
  service.openOrder(
    orderId: 'ORD-002',
    tableNumber: 2,
    guestCount: 2,
    waiterId: 'W01',
  );
  service.addItemToOrder(
    waiterId: 'W01',
    orderId: 'ORD-002',
    menuItemId: 'M03',
    quantity: 2,
  );
  service.addItemToOrder(
    waiterId: 'W01',
    orderId: 'ORD-002',
    menuItemId: 'M05',
    quantity: 3,
  );
  service.checkoutOrder(
    orderId: 'ORD-002',
    cashierId: 'K01',
    discountCode: 'SAVE20',
  );
  service.openOrder(
    orderId: 'ORD-003',
    tableNumber: 3,
    guestCount: 2,
    waiterId: 'W01',
  );

  service.cancelOrder(
    waiterId: 'W01',
    orderId: 'ORD-003',
  );

  runApp(RestaurantApp(service: service));
}
// class RestaurantApp extends StatelessWidget {
//   final RestaurantService service;

//   const RestaurantApp({
//     super.key,
//     required this.service,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Restaurant System',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         useMaterial3: true,
//         colorSchemeSeed: Colors.brown,
//       ),
//       home: RestaurantHomeScreen(
//         service: service,
//       ),
//     );
//   }
// }
class RestaurantApp extends StatelessWidget {
  final RestaurantService service;

  const RestaurantApp({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    final table = service.tables.firstWhere(
      (table) => table.tableNumber == 1,
    );

    final order = service.orders.firstWhere(
      (order) => order.id == 'ORD-001',
    );

    return MaterialApp(
      title: 'Restaurant System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.brown,
      ),
      home: TableDetailScreen(
        table: table,
        order: order,
      ),
    );
  }
}

// class RestaurantHomeScreen extends StatelessWidget {
//   final RestaurantService service;

//   const RestaurantHomeScreen({
//     super.key,
//     required this.service,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final order = service.orders.first;

//     return AddMenuItemToOrderForm(
//       order: order,
//       menu: service.menu,
//     );
//   }
// }
