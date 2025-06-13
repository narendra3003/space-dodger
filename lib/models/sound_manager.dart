import 'package:audioplayers/audioplayers.dart';

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioPlayer _backgroundPlayer = AudioPlayer();
  bool _isEnabled = true;

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) {
      stopBackgroundMusic();
    }
  }

  Future<void> playCoinSound() async {
    if (!_isEnabled) return;
    
    try {
      await _audioPlayer.play(AssetSource('sounds/coin.mp3'));
    } catch (e) {
      // error silently ignored
    }
  }

  Future<void> playGameOverSound() async {
    if (!_isEnabled) return;
    
    try {
      await _audioPlayer.play(AssetSource('sounds/game-over.mp3'));
    } catch (e) {
      // error silently ignored
    }
  }

  Future<void> playExplosionSound() async {
    if (!_isEnabled) return;
    
    try {
      await _audioPlayer.play(AssetSource('sounds/explosion.mp3'));
    } catch (e) {
      // print('Error playing explosion sound: $e');
    }
  }

  Future<void> playBackgroundMusic() async {
    if (!_isEnabled) return;
    
    try {
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer.play(AssetSource('sounds/background.mp3'));
    } catch (e) {
      // print('Error playing background music: $e');
    }
  }

  void stopBackgroundMusic() async {
    try {
      await _backgroundPlayer.stop();
    } catch (e) {
      // print('Error stopping background music: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
    _backgroundPlayer.dispose();
  }
} 