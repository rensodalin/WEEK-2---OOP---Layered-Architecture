class RestaurantTable {
  final int tableNumber;
  final int capacity;
  bool _isOccupied = false; //private file , external code cannot directly change it  so isteadn it control it own internal state through meeaningfule method 

  RestaurantTable({
    required this.tableNumber,
    required this.capacity,
  });

  bool get isOccupied => _isOccupied;

  void occupy() { // node if put in inside the service ?? so anyonce can change this anywhere without rules !
    _isOccupied = true;
  }

  void release() {
    _isOccupied = false;
  }
}
