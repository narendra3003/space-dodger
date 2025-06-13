import 'package:flutter/material.dart';
import '../models/game_objects.dart';

class GamePainter extends CustomPainter {
  final Ship ship;
  final List<Bomb> bombs;
  final Coin coin;
  final List<Map<String, dynamic>> particles;
  final List<Map<String, dynamic>> explosions;
  final List<Map<String, dynamic>> engineTrails;

  GamePainter({
    required this.ship,
    required this.bombs,
    required this.coin,
    required this.particles,
    required this.explosions,
    required this.engineTrails,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw engine trails first (behind everything)
    for (final trail in engineTrails) {
      _drawParticle(canvas, trail);
    }
    
    // Draw ship (spaceship shape)
    _drawShip(canvas);
    
    // Draw bombs (asteroids)
    for (final bomb in bombs) {
      _drawBomb(canvas, bomb);
    }

    // Draw coin (star shape)
    _drawCoin(canvas, coin);
    
    // Draw coin collection particles
    for (final particle in particles) {
      _drawParticle(canvas, particle);
    }
    
    // Draw explosion effects (on top)
    for (final explosion in explosions) {
      _drawParticle(canvas, explosion);
    }
  }

  void _drawShip(Canvas canvas) {
    // Draw ship glow
    final glowPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final glowRect = Rect.fromLTWH(
      ship.x - 5,
      ship.y - 5,
      ship.width + 10,
      ship.height + 10,
    );
    canvas.drawRect(glowRect, glowPaint);
    
    final shipPaint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.fill;
    
    final shipBorderPaint = Paint()
      ..color = Colors.lightBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Draw ship body
    final shipRect = Rect.fromLTWH(ship.x, ship.y, ship.width, ship.height);
    canvas.drawRect(shipRect, shipPaint);
    canvas.drawRect(shipRect, shipBorderPaint);
    
    // Draw ship cockpit
    final cockpitPaint = Paint()
      ..color = Colors.cyan
      ..style = PaintingStyle.fill;
    
    final cockpitRect = Rect.fromLTWH(
      ship.x + ship.width * 0.3,
      ship.y + ship.height * 0.2,
      ship.width * 0.4,
      ship.height * 0.3,
    );
    canvas.drawRect(cockpitRect, cockpitPaint);
    
    // Draw ship engine glow
    final enginePaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    
    final engineRect = Rect.fromLTWH(
      ship.x + ship.width * 0.4,
      ship.y + ship.height,
      ship.width * 0.2,
      ship.height * 0.3,
    );
    canvas.drawRect(engineRect, enginePaint);
    
    // Draw engine glow effect
    final engineGlowPaint = Paint()
      ..color = Colors.orange.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    
    final engineGlowRect = Rect.fromLTWH(
      ship.x + ship.width * 0.3,
      ship.y + ship.height,
      ship.width * 0.4,
      ship.height * 0.5,
    );
    canvas.drawRect(engineGlowRect, engineGlowPaint);
  }

  void _drawBomb(Canvas canvas, Bomb bomb) {
    final bombPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    
    final bombBorderPaint = Paint()
      ..color = Colors.red.shade900
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    // Draw bomb body
    final bombRect = Rect.fromLTWH(bomb.x, bomb.y, bomb.width, bomb.height);
    canvas.drawRect(bombRect, bombPaint);
    canvas.drawRect(bombRect, bombBorderPaint);
    
    // Draw bomb details
    final detailPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    
    // Draw some crater-like details
    final detailRect1 = Rect.fromLTWH(
      bomb.x + bomb.width * 0.2,
      bomb.y + bomb.height * 0.3,
      bomb.width * 0.2,
      bomb.height * 0.2,
    );
    canvas.drawOval(detailRect1, detailPaint);
    
    final detailRect2 = Rect.fromLTWH(
      bomb.x + bomb.width * 0.6,
      bomb.y + bomb.height * 0.6,
      bomb.width * 0.15,
      bomb.height * 0.15,
    );
    canvas.drawOval(detailRect2, detailPaint);
  }

  void _drawCoin(Canvas canvas, Coin coin) {
    // Draw coin glow
    final glowPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.4)
      ..style = PaintingStyle.fill;
    
    final glowRect = Rect.fromLTWH(
      coin.x - 3,
      coin.y - 3,
      coin.width + 6,
      coin.height + 6,
    );
    canvas.drawOval(glowRect, glowPaint);
    
    final coinPaint = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.fill;
    
    final coinBorderPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Draw coin body
    final coinRect = Rect.fromLTWH(coin.x, coin.y, coin.width, coin.height);
    canvas.drawOval(coinRect, coinPaint);
    canvas.drawOval(coinRect, coinBorderPaint);
    
    // Draw coin center
    final centerPaint = Paint()
      ..color = Colors.orange
      ..style = PaintingStyle.fill;
    
    final centerRect = Rect.fromLTWH(
      coin.x + coin.width * 0.3,
      coin.y + coin.height * 0.3,
      coin.width * 0.4,
      coin.height * 0.4,
    );
    canvas.drawOval(centerRect, centerPaint);
    
    // Draw star symbol
    final starPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    final starRect = Rect.fromLTWH(
      coin.x + coin.width * 0.4,
      coin.y + coin.height * 0.4,
      coin.width * 0.2,
      coin.height * 0.2,
    );
    canvas.drawOval(starRect, starPaint);
    
    // Draw inner glow
    final innerGlowPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    
    final innerGlowRect = Rect.fromLTWH(
      coin.x + coin.width * 0.2,
      coin.y + coin.height * 0.2,
      coin.width * 0.6,
      coin.height * 0.6,
    );
    canvas.drawOval(innerGlowRect, innerGlowPaint);
  }

  void _drawParticle(Canvas canvas, Map<String, dynamic> particle) {
    String type = particle['type'] ?? 'coin';
    double size = particle['size'] ?? 3.0;
    double maxLife = type == 'explosion' ? 60.0 : (type == 'engine' ? 20.0 : 30.0);
    double opacity = particle['life'] / maxLife;
    
    final particlePaint = Paint()
      ..color = (particle['color'] as Color).withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    final particleRect = Rect.fromLTWH(
      particle['x'],
      particle['y'],
      size,
      size,
    );
    
    // Draw different shapes based on particle type
    if (type == 'explosion') {
      // Explosion particles are larger and more varied
      canvas.drawOval(particleRect, particlePaint);
      
      // Add glow effect for explosions
      final glowPaint = Paint()
        ..color = (particle['color'] as Color).withOpacity(opacity * 0.3)
        ..style = PaintingStyle.fill;
      
      final glowRect = Rect.fromLTWH(
        particle['x'] - 2,
        particle['y'] - 2,
        size + 4,
        size + 4,
      );
      canvas.drawOval(glowRect, glowPaint);
    } else if (type == 'engine') {
      // Engine trails are smaller and more elongated
      final trailRect = Rect.fromLTWH(
        particle['x'],
        particle['y'],
        size * 0.5,
        size * 2,
      );
      canvas.drawOval(trailRect, particlePaint);
    } else {
      // Coin particles are standard circles
      canvas.drawOval(particleRect, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
