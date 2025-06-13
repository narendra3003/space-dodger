import 'package:flutter/material.dart';

class SettingsPanel extends StatefulWidget {
  final bool coinMagnet;
  final double difficulty;
  final double gameSpeed;
  final int lives;
  final int maxScore;
  final bool soundEnabled;
  final bool visualEffects;
  final Function(bool) onCoinMagnetChanged;
  final Function(double) onDifficultyChanged;
  final Function(double) onGameSpeedChanged;
  final Function(int) onLivesChanged;
  final Function(bool) onSoundEnabledChanged;
  final Function(bool) onVisualEffectsChanged;

  const SettingsPanel({
    super.key,
    required this.coinMagnet,
    required this.difficulty,
    required this.gameSpeed,
    required this.lives,
    required this.maxScore,
    required this.soundEnabled,
    required this.visualEffects,
    required this.onCoinMagnetChanged,
    required this.onDifficultyChanged,
    required this.onGameSpeedChanged,
    required this.onLivesChanged,
    required this.onSoundEnabledChanged,
    required this.onVisualEffectsChanged,
  });

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  late bool _coinMagnet;
  late double _difficulty;
  late double _gameSpeed;
  late int _lives;
  late bool _soundEnabled;
  late bool _visualEffects;

  @override
  void initState() {
    super.initState();
    _coinMagnet = widget.coinMagnet;
    _difficulty = widget.difficulty;
    _gameSpeed = widget.gameSpeed;
    _lives = widget.lives;
    _soundEnabled = widget.soundEnabled;
    _visualEffects = widget.visualEffects;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Game Settings',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Max Score Display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Max Score: ${widget.maxScore}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Lives Setting
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.favorite, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'Lives: $_lives',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [1, 2, 3].map((lifeCount) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _lives = lifeCount;
                          });
                          widget.onLivesChanged(lifeCount);
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _lives >= lifeCount ? Colors.red : Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _lives >= lifeCount ? Colors.red : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.favorite,
                            color: _lives >= lifeCount ? Colors.white : Colors.grey,
                            size: 20,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Difficulty Setting
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.trending_up, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Difficulty: ${_difficulty.toStringAsFixed(1)}x',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _difficulty,
                    min: 0.5,
                    max: 6.0,
                    divisions: 11, // 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0
                    label: '${_difficulty.toStringAsFixed(1)}x',
                    onChanged: (value) {
                      setState(() {
                        _difficulty = value;
                      });
                      widget.onDifficultyChanged(value);
                    },
                  ),
                  const Text(
                    'Higher difficulty = more bombs & better scoring',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Game Speed Setting
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.speed, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Game Speed: ${_gameSpeed.toStringAsFixed(0)}ms',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Slider(
                    value: _gameSpeed,
                    min: 30.0,
                    max: 120.0,
                    divisions: 9,
                    label: '${_gameSpeed.toStringAsFixed(0)}ms',
                    onChanged: (value) {
                      setState(() {
                        _gameSpeed = value;
                      });
                      widget.onGameSpeedChanged(value);
                    },
                  ),
                  const Text(
                    'Lower = faster, Higher = slower',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Coin Magnet Setting
            SwitchListTile(
              title: const Text('Coin Magnet'),
              subtitle: const Text('Collect coins from any height'),
              value: _coinMagnet,
              onChanged: (value) {
                setState(() {
                  _coinMagnet = value;
                });
                widget.onCoinMagnetChanged(value);
              },
            ),
            
            const Divider(),
            
            // Sound Setting
            SwitchListTile(
              title: const Text('Sound Effects'),
              subtitle: const Text('Enable game sounds'),
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
                widget.onSoundEnabledChanged(value);
              },
            ),
            
            const Divider(),
            
            // Visual Effects Setting
            SwitchListTile(
              title: const Text('Visual Effects'),
              subtitle: const Text('Enable particle effects'),
              value: _visualEffects,
              onChanged: (value) {
                setState(() {
                  _visualEffects = value;
                });
                widget.onVisualEffectsChanged(value);
              },
            ),
            
            const SizedBox(height: 20),
            
            // Game Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to Play:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Use left/right buttons to move\n'
                    '• Avoid red asteroids\n'
                    '• Collect yellow coins\n'
                    '• Score increases with difficulty\n'
                    '• +5 bonus when magnet is off\n'
                    '• Game speeds up over time',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
