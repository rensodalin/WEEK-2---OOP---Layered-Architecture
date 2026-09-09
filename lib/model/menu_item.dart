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

  MenuItem.beverage({
    required this.id,
    required this.name,
    required this.price,
  }) : category = MenuCategory.beverage;

  MenuItem.food({
    required this.id,
    required this.name,
    required this.price,
  }) : category = MenuCategory.food;
}
