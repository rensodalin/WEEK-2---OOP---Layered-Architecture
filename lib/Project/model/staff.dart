enum StaffRole {
  manager,
  waiter,
  cashier,
}

class Staff {
  final String id;
  final String name;
  final StaffRole role;

  Staff({
    required this.id,
    required this.name,
    required this.role,
  });

  bool get isManager => role == StaffRole.manager;
  bool get isWaiter => role == StaffRole.waiter;
  bool get isCashier => role == StaffRole.cashier;
}
