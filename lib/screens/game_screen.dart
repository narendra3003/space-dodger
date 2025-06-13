import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../models/game_objects.dart';
import '../models/sound_manager.dart';
import '../widgets/game_painter.dart';
import '../widgets/settings_panel.dart';
import '../widgets/space_background.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  Timer? _gameTimer;
  Timer? _leftMoveTimer;
  Timer? _rightMoveTimer;
  late Ship _ship;
  late List<Bomb> _bombs;
  late Coin _coin;
  
  int _score = 0;
  int _lives = 3; // Default 3 lives
  int _maxScore = 0; // Track max score
  bool _gameOver = false;
  bool _gamePaused = false;
  bool _gameStarted = false;
  
  // Button states for continuous movement
  bool _isLeftPressed = false;
  bool _isRightPressed = false;
  
  // Game settings
  double _gameSpeed = 60.0; // Slower initial speed for better control
  double _baseGameSpeed = 60.0; // Base speed for calculations
  bool _coinMagnet = true;
  double _difficulty = 1.0;
  bool _soundEnabled = true;
  bool _visualEffects = true;
  
  // Screen dimensions
  late double _screenWidth;
  late double _screenHeight;
  
  // Game constants - improved for better progression
  static const double spaceSize = 20.0;
  static const double shipSize = 3.0;
  static const double bombSize = 1.5;
  static const double maxSpeed = 30.0; // Faster max speed
  static const double minSpeed = 120.0; // Slower min speed
  
  // Visual effects
  final List<Map<String, dynamic>> _particles = [];
  final List<Map<String, dynamic>> _engineTrails = [];
  final List<Map<String, dynamic>> _explosions = [];
  
  // Score animation
  double _scoreScale = 1.0;
  Color _scoreColor = Colors.white;
  
  // Sound manager
  final SoundManager _soundManager = SoundManager();

  @override
  void initState() {
    super.initState();
    
    // Initialize sound manager
    _soundManager.setEnabled(_soundEnabled);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  void _initializeGame() {
    final size = MediaQuery.of(context).size;
    _screenWidth = size.width;
    _screenHeight = size.height - 200; // Account for UI elements
    
    _ship = Ship(
      x: _screenWidth / 2 - (shipSize * spaceSize) / 2,
      y: _screenHeight - 80,
      size: shipSize,
      spaceSize: spaceSize,
    );
    
    _bombs = [];
    _coin = _createNewCoin();
    _score = 0;
    _lives = 3; // Reset lives
    _gameOver = false;
    _gamePaused = false;
    _gameStarted = false;
    _gameSpeed = _baseGameSpeed;
    
    setState(() {});
  }

  Coin _createNewCoin() {
    return Coin(
      x: Random().nextDouble() * (_screenWidth - spaceSize),
      y: -spaceSize, // Start above screen
      spaceSize: spaceSize,
    );
  }

  void _startGame() {
    if (_gameStarted && !_gameOver) return;
    
    _gameStarted = true;
    _gameOver = false;
    _gamePaused = false;
    
    // Start background music
    if (_soundEnabled) {
      _soundManager.playBackgroundMusic();
    }
    
    if (_gameTimer?.isActive == true) _gameTimer!.cancel();
    
    _gameTimer = Timer.periodic(
      Duration(milliseconds: _gameSpeed.toInt()),
      (timer) => _gameLoop(),
    );
    
    setState(() {});
  }

  void _gameLoop() {
    if (_gamePaused || _gameOver) return;

    // Move bombs
    for (int i = _bombs.length - 1; i >= 0; i--) {
      _bombs[i].move();
      
      // Remove bombs that are off screen
      if (_bombs[i].y > _screenHeight) {
        _bombs.removeAt(i);
        continue;
      }
      
      // Check collision with ship
      if (_checkCollision(_ship, _bombs[i])) {
        _handleCollision();
        return;
      }
    }

    // Move coin
    _coin.move();
    
    // Check coin collection
    if (_checkCoinCollection(_ship, _coin)) {
      _handleCoinCollection();
    } else if (_coin.y > _screenHeight) {
      _coin = _createNewCoin();
    }

    // Create new bomb with improved difficulty-based probability
    _createBombsWithDifficulty();

    // Update particles
    if (_visualEffects) {
      _updateParticles();
    }

    setState(() {});
  }

  void _handleCollision() {
    _lives--;
    
    // Add explosion effect at ship position
    if (_visualEffects) {
      _addExplosionEffect(_ship.x + _ship.width / 2, _ship.y + _ship.height / 2);
    }
    
    // Play explosion sound
    if (_soundEnabled) {
      _soundManager.playExplosionSound();
    }
    
    if (_lives <= 0) {
      _endGame();
    } else {
      // Reset ship position and continue
      _ship.x = _screenWidth / 2 - (_ship.width) / 2;
      _ship.y = _screenHeight - 80;
      
      // Clear some bombs to give player a chance
      if (_bombs.length > 3) {
        _bombs.removeRange(0, _bombs.length - 3);
      }
    }
  }

  void _handleCoinCollection() {
    // Calculate score based on difficulty and coin magnet setting
    int baseScore = 1;
    int difficultyBonus = (_difficulty * baseScore).round();
    int magnetBonus = _coinMagnet ? 0 : 5; // +5 bonus when magnet is off
    
    int totalScore = difficultyBonus + magnetBonus;
    _score += totalScore;
    
    // Animate score
    _animateScore();
    
    // Play sound effect
    if (_soundEnabled) {
      _soundManager.playCoinSound();
    }
    
    // Add visual effects
    if (_visualEffects) {
      _addCoinCollectionEffect(_coin.x, _coin.y);
    }
    
    _coin = _createNewCoin();
    _updateGameSpeed();
  }

  void _createBombsWithDifficulty() {
    // Improved difficulty progression based on score and difficulty setting
    double baseProbability = 0.015; // 1.5% base chance
    double scoreMultiplier = 1.0 + (_score / 50.0); // Increases every 50 points
    double difficultyMultiplier = _difficulty;
    
    // Cap the maximum probability to prevent impossible gameplay
    double maxProbability = 0.12; // 12% maximum chance for higher difficulties
    
    double bombProbability = (baseProbability * scoreMultiplier * difficultyMultiplier)
        .clamp(baseProbability, maxProbability);
    
    if (Random().nextDouble() < bombProbability) {
      _bombs.add(Bomb(
        x: Random().nextDouble() * (_screenWidth - spaceSize),
        y: -spaceSize, // Start above screen
        size: bombSize,
        spaceSize: spaceSize,
      ));
    }
  }

  void _updateGameSpeed() {
    // Improved speed progression with better curve
    // Speed increases more gradually and plateaus at higher scores
    
    double speedMultiplier;
    if (_score < 10) {
      // First 10 points: gradual increase
      speedMultiplier = 1.0 + (_score * 0.02);
    } else if (_score < 30) {
      // 10-30 points: moderate increase
      speedMultiplier = 1.2 + ((_score - 10) * 0.015);
    } else if (_score < 60) {
      // 30-60 points: slower increase
      speedMultiplier = 1.5 + ((_score - 30) * 0.01);
    } else {
      // 60+ points: very slow increase, approaching max
      speedMultiplier = 1.8 + ((_score - 60) * 0.005);
    }
    
    // Calculate new speed with smooth curve, but respect user's speed setting
    double newSpeed = _baseGameSpeed / speedMultiplier;
    _gameSpeed = newSpeed.clamp(maxSpeed, minSpeed);
    
    // Update game timer
    if (_gameTimer?.isActive == true) {
      _gameTimer!.cancel();
      _gameTimer = Timer.periodic(
        Duration(milliseconds: _gameSpeed.toInt()),
        (timer) => _gameLoop(),
      );
    }
  }

  bool _checkCollision(Ship ship, Bomb bomb) {
    // Improved collision detection with some tolerance
    double tolerance = 5.0;
    return !(ship.x + ship.width - tolerance < bomb.x || 
             bomb.x + bomb.width - tolerance < ship.x ||
             ship.y + ship.height - tolerance < bomb.y ||
             bomb.y + bomb.height - tolerance < ship.y);
  }

  bool _checkCoinCollection(Ship ship, Coin coin) {
    if (_coinMagnet) {
      // Coin magnet: collect coins from any height if horizontally aligned
      bool xOverlap = ship.x <= coin.x + coin.width && ship.x + ship.width >= coin.x;
      return xOverlap;
    } else {
      // Normal collection: must be close vertically
      bool xOverlap = ship.x <= coin.x + coin.width && ship.x + ship.width >= coin.x;
      bool yOverlap = ship.y <= coin.y + coin.height && ship.y + ship.height >= coin.y;
      return xOverlap && yOverlap;
    }
  }

  void _endGame() {
    _gameOver = true;
    
    // Update max score if current score is higher
    if (_score > _maxScore) {
      _maxScore = _score;
    }
    
    // Play game over sound
    if (_soundEnabled) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _soundManager.playGameOverSound();
      });
    }
    
    // Stop background music
    _soundManager.stopBackgroundMusic();
    
    _gameTimer?.cancel();
    setState(() {});
  }

  void _pauseGame() {
    _gamePaused = !_gamePaused;
    
    // Handle background music
    if (_soundEnabled) {
      if (_gamePaused) {
        _soundManager.stopBackgroundMusic();
      } else {
        _soundManager.playBackgroundMusic();
      }
    }
    
    setState(() {});
  }

  void _restartGame() {
    _gameTimer?.cancel();
    _leftMoveTimer?.cancel();
    _rightMoveTimer?.cancel();
    
    // Stop background music
    _soundManager.stopBackgroundMusic();
    
    _initializeGame();
    setState(() {});
  }

  void _startContinuousMove(String direction) {
    if (_gameOver || _gamePaused || !_gameStarted) return;
    
    if (direction == 'left' && !_isLeftPressed) {
      _isLeftPressed = true;
      _leftMoveTimer?.cancel();
      _leftMoveTimer = Timer.periodic(
        const Duration(milliseconds: 50), // Move every 50ms for smooth movement
        (timer) {
          if (_gameOver || _gamePaused || !_gameStarted || !_isLeftPressed) {
            timer.cancel();
            _isLeftPressed = false;
            return;
          }
          _ship.moveLeft();
          setState(() {});
        },
      );
    } else if (direction == 'right' && !_isRightPressed) {
      _isRightPressed = true;
      _rightMoveTimer?.cancel();
      _rightMoveTimer = Timer.periodic(
        const Duration(milliseconds: 50), // Move every 50ms for smooth movement
        (timer) {
          if (_gameOver || _gamePaused || !_gameStarted || !_isRightPressed) {
            timer.cancel();
            _isRightPressed = false;
            return;
          }
          _ship.moveRight(_screenWidth);
          setState(() {});
        },
      );
    }
  }

  void _stopContinuousMove(String direction) {
    if (direction == 'left') {
      _isLeftPressed = false;
      _leftMoveTimer?.cancel();
    } else if (direction == 'right') {
      _isRightPressed = false;
      _rightMoveTimer?.cancel();
    }
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) => SettingsPanel(
        coinMagnet: _coinMagnet,
        difficulty: _difficulty,
        gameSpeed: _baseGameSpeed,
        lives: _lives,
        maxScore: _maxScore,
        soundEnabled: _soundEnabled,
        visualEffects: _visualEffects,
        onCoinMagnetChanged: (value) => setState(() => _coinMagnet = value),
        onDifficultyChanged: (value) => setState(() => _difficulty = value),
        onGameSpeedChanged: (value) {
          setState(() {
            _baseGameSpeed = value;
            _gameSpeed = value;
          });
          // Update game timer with new speed
          if (_gameTimer?.isActive == true) {
            _gameTimer!.cancel();
            _gameTimer = Timer.periodic(
              Duration(milliseconds: _gameSpeed.toInt()),
              (timer) => _gameLoop(),
            );
          }
        },
        onLivesChanged: (value) => setState(() => _lives = value),
        onSoundEnabledChanged: (value) {
          setState(() => _soundEnabled = value);
          _soundManager.setEnabled(value);
        },
        onVisualEffectsChanged: (value) => setState(() => _visualEffects = value),
      ),
    );
  }

  void _animateScore() {
    setState(() {
      _scoreScale = 1.3;
      _scoreColor = Colors.yellow;
    });
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _scoreScale = 1.0;
          _scoreColor = Colors.white;
        });
      }
    });
  }

  void _addCoinCollectionEffect(double x, double y) {
    // Create particle effects for coin collection
    for (int i = 0; i < 8; i++) {
      _particles.add({
        'x': x + Random().nextDouble() * 20 - 10,
        'y': y + Random().nextDouble() * 20 - 10,
        'vx': (Random().nextDouble() - 0.5) * 4,
        'vy': (Random().nextDouble() - 0.5) * 4,
        'life': 30,
        'color': Colors.yellow,
        'type': 'coin',
      });
    }
  }

  void _addExplosionEffect(double x, double y) {
    // Create explosion effect
    for (int i = 0; i < 15; i++) {
      _explosions.add({
        'x': x + Random().nextDouble() * 40 - 20,
        'y': y + Random().nextDouble() * 40 - 20,
        'vx': (Random().nextDouble() - 0.5) * 8,
        'vy': (Random().nextDouble() - 0.5) * 8,
        'life': 60,
        'color': [Colors.red, Colors.orange, Colors.yellow][Random().nextInt(3)],
        'size': Random().nextDouble() * 4 + 2,
        'type': 'explosion',
      });
    }
  }

  void _addEngineTrailEffect() {
    // Add engine trail effect behind the ship
    if (_visualEffects && _gameStarted && !_gameOver && !_gamePaused) {
      _engineTrails.add({
        'x': _ship.x + _ship.width * 0.4 + Random().nextDouble() * _ship.width * 0.2,
        'y': _ship.y + _ship.height,
        'vx': (Random().nextDouble() - 0.5) * 2,
        'vy': Random().nextDouble() * 3 + 2,
        'life': 20,
        'color': [Colors.orange, Colors.yellow, Colors.red][Random().nextInt(3)],
        'size': Random().nextDouble() * 3 + 1,
        'type': 'engine',
      });
    }
  }

  void _updateParticles() {
    // Update coin collection particles
    for (int i = _particles.length - 1; i >= 0; i--) {
      _particles[i]['x'] += _particles[i]['vx'];
      _particles[i]['y'] += _particles[i]['vy'];
      _particles[i]['life']--;
      
      if (_particles[i]['life'] <= 0) {
        _particles.removeAt(i);
      }
    }

    // Update explosion effects
    for (int i = _explosions.length - 1; i >= 0; i--) {
      _explosions[i]['x'] += _explosions[i]['vx'];
      _explosions[i]['y'] += _explosions[i]['vy'];
      _explosions[i]['life']--;
      
      if (_explosions[i]['life'] <= 0) {
        _explosions.removeAt(i);
      }
    }

    // Update engine trail effects
    for (int i = _engineTrails.length - 1; i >= 0; i--) {
      _engineTrails[i]['x'] += _engineTrails[i]['vx'];
      _engineTrails[i]['y'] += _engineTrails[i]['vy'];
      _engineTrails[i]['life']--;
      
      if (_engineTrails[i]['life'] <= 0) {
        _engineTrails.removeAt(i);
      }
    }

    // Add new engine trail effect
    _addEngineTrailEffect();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _leftMoveTimer?.cancel();
    _rightMoveTimer?.cancel();
    _soundManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Update screen dimensions when build is called
    final size = MediaQuery.of(context).size;
    _screenWidth = size.width;
    _screenHeight = size.height - 200;
    
    return SpaceBackground(
      isGameActive: _gameStarted && !_gamePaused && !_gameOver,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.black.withOpacity(0.7),
          elevation: 0,
          title: Row(
            children: [
              Expanded(
                child: AnimatedScale(
                  scale: _scoreScale,
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    'Score: $_score',
                    style: TextStyle(
                      color: _scoreColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: const [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Lives display
              Row(
                children: List.generate(_lives, (index) => 
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: _showSettings,
            ),
            IconButton(
              icon: Icon(
                _gamePaused ? Icons.play_arrow : Icons.pause,
                color: Colors.white,
              ),
              onPressed: _gameStarted ? _pauseGame : null,
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _restartGame,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                child: Stack(
                  children: [
                    // Game Canvas
                    CustomPaint(
                      size: Size(_screenWidth, _screenHeight),
                      painter: GamePainter(
                        ship: _ship,
                        bombs: _bombs,
                        coin: _coin,
                        particles: _particles,
                        explosions: _explosions,
                        engineTrails: _engineTrails,
                      ),
                    ),
                    
                    // Game Over Overlay
                    if (_gameOver)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x4DFF0000), // Colors.red.withOpacity(0.3)
                              Color(0xB3000000), // Colors.black.withOpacity(0.7)
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'GAME OVER',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                'Final Score: $_score',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              ElevatedButton(
                                onPressed: _restartGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 30,
                                    vertical: 15,
                                  ),
                                ),
                                child: const Text(
                                  'Play Again',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Pause Overlay
                    if (_gamePaused && !_gameOver)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0x99000000), // Colors.black.withOpacity(0.6)
                        ),
                        child: const Center(
                          child: Text(
                            'PAUSED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.blue,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    
                    // Start Game Overlay
                    if (!_gameStarted && !_gameOver)
                      Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x4D2196F3), // Colors.blue.withOpacity(0.3)
                              Color(0x99000000), // Colors.black.withOpacity(0.6)
                            ],
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'SPACE DODGER',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white,
                                      blurRadius: 15,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'Avoid the red bombs\nCollect the yellow coins',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              ElevatedButton(
                                onPressed: _startGame,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 20,
                                  ),
                                ),
                                child: const Text(
                                  'START GAME',
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.grey[900]!.withOpacity(0.8),
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTapDown: (_) => _startContinuousMove('left'),
                    onTapUp: (_) => _stopContinuousMove('left'),
                    onTapCancel: () => _stopContinuousMove('left'),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _isLeftPressed ? Colors.blue[700] : Colors.blue,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_left,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTapDown: (_) => _startContinuousMove('right'),
                    onTapUp: (_) => _stopContinuousMove('right'),
                    onTapCancel: () => _stopContinuousMove('right'),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: _isRightPressed ? Colors.blue[700] : Colors.blue,
                        borderRadius: BorderRadius.circular(40),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.5),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_right,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
