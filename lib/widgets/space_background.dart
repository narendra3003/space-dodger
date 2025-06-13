import 'package:flutter/material.dart';
import 'dart:math';

class SpaceBackground extends StatefulWidget {
  final Widget child;
  final bool isGameActive;

  const SpaceBackground({
    super.key,
    required this.child,
    required this.isGameActive,
  });

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _nebulaController;
  late AnimationController _planetController;
  
  final List<Map<String, dynamic>> _stars = [];
  final List<Map<String, dynamic>> _nebulas = [];
  final List<Map<String, dynamic>> _planets = [];
  final List<Map<String, dynamic>> _shootingStars = [];
  final List<Map<String, dynamic>> _asteroids = [];
  
  @override
  void initState() {
    super.initState();
    
    _starController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
    
    _nebulaController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    _planetController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    )..repeat();
    
    _initializeStars();
    _initializeNebulas();
    _initializePlanets();
    _initializeShootingStars();
    _initializeAsteroids();
  }

  void _initializeStars() {
    final random = Random();
    for (int i = 0; i < 100; i++) {
      _stars.add({
        'x': random.nextDouble() * 400,
        'y': random.nextDouble() * 800,
        'size': random.nextDouble() * 2 + 0.5,
        'brightness': random.nextDouble() * 0.8 + 0.2,
        'twinkleSpeed': random.nextDouble() * 2 + 1,
        'color': [
          Colors.white,
          Colors.blue.shade200,
          Colors.cyan.shade200,
          Colors.yellow.shade200,
        ][random.nextInt(4)],
      });
    }
  }

  void _initializeNebulas() {
    final random = Random();
    for (int i = 0; i < 3; i++) {
      _nebulas.add({
        'x': random.nextDouble() * 300,
        'y': random.nextDouble() * 600,
        'size': random.nextDouble() * 150 + 100,
        'color': [
          Colors.purple.withOpacity(0.1),
          Colors.blue.withOpacity(0.1),
          Colors.pink.withOpacity(0.1),
        ][random.nextInt(3)],
        'rotation': random.nextDouble() * 360,
      });
    }
  }

  void _initializePlanets() {
    final random = Random();
    for (int i = 0; i < 2; i++) {
      _planets.add({
        'x': random.nextDouble() * 200 + 100,
        'y': random.nextDouble() * 400 + 200,
        'size': random.nextDouble() * 30 + 20,
        'color': [
          Colors.orange.shade300,
          Colors.red.shade300,
          Colors.blue.shade300,
        ][random.nextInt(3)],
        'orbitRadius': random.nextDouble() * 50 + 30,
        'orbitSpeed': random.nextDouble() * 0.02 + 0.01,
        'orbitAngle': random.nextDouble() * 360,
      });
    }
  }

  void _initializeShootingStars() {
    final random = Random();
    for (int i = 0; i < 5; i++) {
      _shootingStars.add({
        'x': random.nextDouble() * 400,
        'y': random.nextDouble() * 800,
        'vx': random.nextDouble() * 3 + 2,
        'vy': random.nextDouble() * 2 + 1,
        'size': random.nextDouble() * 3 + 1,
        'life': random.nextDouble() * 100 + 50,
        'maxLife': random.nextDouble() * 100 + 50,
        'color': Colors.white,
        'trail': [],
      });
    }
  }

  void _initializeAsteroids() {
    final random = Random();
    for (int i = 0; i < 8; i++) {
      _asteroids.add({
        'x': random.nextDouble() * 400,
        'y': random.nextDouble() * 800,
        'vx': (random.nextDouble() - 0.5) * 0.5,
        'vy': random.nextDouble() * 0.3 + 0.1,
        'size': random.nextDouble() * 4 + 2,
        'rotation': random.nextDouble() * 360,
        'rotationSpeed': (random.nextDouble() - 0.5) * 2,
        'color': Colors.grey.shade600,
      });
    }
  }

  void _updateShootingStars() {
    final random = Random();
    for (int i = _shootingStars.length - 1; i >= 0; i--) {
      final star = _shootingStars[i];
      star['life'] = (star['life'] ?? 0) - 1;
      
      if (star['life'] <= 0) {
        // Reset shooting star
        star['x'] = random.nextDouble() * 400;
        star['y'] = random.nextDouble() * 800;
        star['vx'] = random.nextDouble() * 3 + 2;
        star['vy'] = random.nextDouble() * 2 + 1;
        star['life'] = random.nextDouble() * 100 + 50;
        star['maxLife'] = star['life'];
        star['trail'] = [];
      } else {
        // Update trail
        final t = star['life'] / star['maxLife'];
        final xPos = star['x'] + star['vx'] * (1 - t);
        final yPos = star['y'] + star['vy'] * (1 - t);
        
        star['trail'].add({'x': xPos, 'y': yPos});
        if (star['trail'].length > 10) {
          star['trail'].removeAt(0);
        }
      }
    }
  }

  void _updateAsteroids() {
    for (final asteroid in _asteroids) {
      asteroid['x'] += asteroid['vx'];
      asteroid['y'] += asteroid['vy'];
      asteroid['rotation'] += asteroid['rotationSpeed'];
      
      // Wrap around screen
      if (asteroid['x'] < -50) asteroid['x'] = 450;
      if (asteroid['x'] > 450) asteroid['x'] = -50;
      if (asteroid['y'] < -50) asteroid['y'] = 850;
      if (asteroid['y'] > 850) asteroid['y'] = -50;
    }
  }

  @override
  void dispose() {
    _starController.dispose();
    _nebulaController.dispose();
    _planetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Animated space background
        AnimatedBuilder(
          animation: Listenable.merge([
            _starController,
            _nebulaController,
            _planetController,
          ]),
          builder: (context, child) {
            _updateShootingStars();
            _updateAsteroids();
            return CustomPaint(
              size: Size.infinite,
              painter: SpaceBackgroundPainter(
                stars: _stars,
                nebulas: _nebulas,
                planets: _planets,
                shootingStars: _shootingStars,
                asteroids: _asteroids,
                starAnimation: _starController.value,
                nebulaAnimation: _nebulaController.value,
                planetAnimation: _planetController.value,
                isGameActive: widget.isGameActive,
              ),
            );
          },
        ),
        
        // Gradient overlay for depth
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.3),
                Colors.black.withOpacity(0.1),
              ],
              stops: const [0.0, 0.7, 1.0],
            ),
          ),
        ),
        
        // Main content
        widget.child,
      ],
    );
  }
}

class SpaceBackgroundPainter extends CustomPainter {
  final List<Map<String, dynamic>> stars;
  final List<Map<String, dynamic>> nebulas;
  final List<Map<String, dynamic>> planets;
  final List<Map<String, dynamic>> shootingStars;
  final List<Map<String, dynamic>> asteroids;
  final double starAnimation;
  final double nebulaAnimation;
  final double planetAnimation;
  final bool isGameActive;

  SpaceBackgroundPainter({
    required this.stars,
    required this.nebulas,
    required this.planets,
    required this.shootingStars,
    required this.asteroids,
    required this.starAnimation,
    required this.nebulaAnimation,
    required this.planetAnimation,
    required this.isGameActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw nebulas
    for (final nebula in nebulas) {
      _drawNebula(canvas, nebula, size);
    }

    // Draw planets
    for (final planet in planets) {
      _drawPlanet(canvas, planet, size);
    }

    // Draw asteroids
    for (final asteroid in asteroids) {
      _drawAsteroid(canvas, asteroid, size);
    }

    // Draw stars
    for (final star in stars) {
      _drawStar(canvas, star, size);
    }

    // Draw shooting stars
    for (final shootingStar in shootingStars) {
      _drawShootingStar(canvas, shootingStar, size);
    }
  }

  void _drawNebula(Canvas canvas, Map<String, dynamic> nebula, Size size) {
    final centerX = nebula['x'];
    final centerY = nebula['y'] + nebulaAnimation * 50; // Slow movement
    final nebulaSize = nebula['size'];

    // Draw nebula as multiple overlapping circles
    for (int i = 0; i < 5; i++) {
      final offset = i * 20.0;
      final opacity = 0.1 - (i * 0.02);
      final nebulaPaint = Paint()
        ..color = nebula['color'].withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(centerX + offset, centerY + offset),
        nebulaSize - (i * 10),
        nebulaPaint,
      );
    }
  }

  void _drawPlanet(Canvas canvas, Map<String, dynamic> planet, Size size) {
    final orbitRadius = planet['orbitRadius'];
    final orbitAngle = planet['orbitAngle'] + planetAnimation * 360;
    final orbitX = planet['x'] + cos(orbitAngle * pi / 180) * orbitRadius;
    final orbitY = planet['y'] + sin(orbitAngle * pi / 180) * orbitRadius;

    final paint = Paint()
      ..color = planet['color']
      ..style = PaintingStyle.fill;

    // Draw planet
    canvas.drawCircle(
      Offset(orbitX, orbitY),
      planet['size'],
      paint,
    );

    // Draw planet glow
    final glowPaint = Paint()
      ..color = planet['color'].withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(orbitX, orbitY),
      planet['size'] + 5,
      glowPaint,
    );
  }

  void _drawStar(Canvas canvas, Map<String, dynamic> star, Size size) {
    final x = star['x'];
    final y = star['y'] + (isGameActive ? starAnimation * 2 : 0); // Move faster when game is active
    final size = star['size'];
    final brightness = star['brightness'];
    final twinkleSpeed = star['twinkleSpeed'];
    final color = star['color'];

    // Twinkle effect
    final twinkle = (sin(starAnimation * 2 * pi * twinkleSpeed) + 1) / 2;
    final finalBrightness = brightness * (0.5 + twinkle * 0.5);

    final paint = Paint()
      ..color = color.withOpacity(finalBrightness)
      ..style = PaintingStyle.fill;

    // Draw star
    canvas.drawCircle(
      Offset(x, y),
      size,
      paint,
    );

    // Draw star glow
    final glowPaint = Paint()
      ..color = color.withOpacity(finalBrightness * 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(x, y),
      size + 2,
      glowPaint,
    );
  }

  void _drawAsteroid(Canvas canvas, Map<String, dynamic> asteroid, Size size) {
    final x = asteroid['x'];
    final y = asteroid['y'];
    final asteroidSize = asteroid['size'];
    final color = asteroid['color'];

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw asteroid
    canvas.drawCircle(
      Offset(x, y),
      asteroidSize,
      paint,
    );

    // Draw asteroid glow
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(x, y),
      asteroidSize + 2,
      glowPaint,
    );
  }

  void _drawShootingStar(Canvas canvas, Map<String, dynamic> shootingStar, Size size) {
    final x = shootingStar['x'];
    final y = shootingStar['y'];
    final vx = shootingStar['vx'];
    final vy = shootingStar['vy'];
    final size = shootingStar['size'];
    final life = shootingStar['life'];
    final maxLife = shootingStar['maxLife'];
    final color = shootingStar['color'];
    final trail = shootingStar['trail'];

    final t = life / maxLife;
    final xPos = x + vx * t;
    final yPos = y + vy * t;

    final paint = Paint()
      ..color = color.withOpacity(1.0 - t)
      ..style = PaintingStyle.fill;

    // Draw shooting star
    canvas.drawCircle(
      Offset(xPos, yPos),
      size,
      paint,
    );

    // Draw shooting star trail
    if (trail.isNotEmpty) {
      for (int i = 0; i < trail.length - 1; i++) {
        final startX = trail[i]['x'];
        final startY = trail[i]['y'];
        final endX = trail[i + 1]['x'];
        final endY = trail[i + 1]['y'];

        canvas.drawLine(
          Offset(startX, startY),
          Offset(endX, endY),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
} 