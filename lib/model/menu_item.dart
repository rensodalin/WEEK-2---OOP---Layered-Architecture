enum MenuCategory {
  beverage,
  food,
}

class MenuItem {
  final String id;
  final String name;
  final double price;
  final MenuCategory category;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
  });

  // Named constructor for beverages
  MenuItem.beverage({
    required this.id,
    required this.name,
    required this.price,
  }) : category = MenuCategory.beverage;

  // Named constructor for food dishes
  MenuItem.food({
    required this.id,
    required this.name,
    required this.price,
  }) : category = MenuCategory.food;
}
