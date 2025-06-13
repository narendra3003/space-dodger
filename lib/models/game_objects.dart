class Ship {
  double x;
  double y;
  final double size;
  final double spaceSize;
  late double width;
  late double height;

  Ship({
    required this.x,
    required this.y,
    required this.size,
    required this.spaceSize,
  }) {
    width = size * spaceSize;
    height = spaceSize;
  }

  void moveLeft() {
    if (x > 0) {
      x -= spaceSize;
    }
  }

  void moveRight(double screenWidth) {
    if (x < screenWidth - width) {
      x += spaceSize;
    }
  }
}

class Bomb {
  double x;
  double y;
  final double size;
  final double spaceSize;
  late double width;
  late double height;

  Bomb({
    required this.x,
    required this.y,
    required this.size,
    required this.spaceSize,
  }) {
    width = size * spaceSize;
    height = spaceSize;
  }

  void move() {
    y += spaceSize;
  }
}

class Coin {
  double x;
  double y;
  final double spaceSize;
  late double width;
  late double height;

  Coin({
    required this.x,
    required this.y,
    required this.spaceSize,
  }) {
    width = spaceSize;
    height = spaceSize;
  }

  void move() {
    y += spaceSize;
  }
}
