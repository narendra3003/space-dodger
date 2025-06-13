import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const SpaceDodgeApp());
}

class SpaceDodgeApp extends StatelessWidget {
  const SpaceDodgeApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    return MaterialApp(
      title: 'Space Dodger',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'monospace',
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
