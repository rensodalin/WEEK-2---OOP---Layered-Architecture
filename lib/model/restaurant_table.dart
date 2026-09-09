class RestaurantTable {
  final int tableNumber;
  final int capacity;
  bool _isOccupied = false;

  RestaurantTable({
    required this.tableNumber,
    required this.capacity,
  });

  bool get isOccupied => _isOccupied;

  void occupy() {
    _isOccupied = true;
  }

  void release() {
    _isOccupied = false;
  }
}
