enum MenuCategory {
  beverage,
  food,
}

class MenuItem {
  String id;
  String name;
  double price;
  MenuCategory category;

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