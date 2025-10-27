import 'package:flutter/material.dart';
import 'screens/menu_screen.dart';

void main() {
  runApp(const VolleyApp());
}

class VolleyApp extends StatelessWidget {
  const VolleyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Die Herren Bier gewinnt eh',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const MenuScreen(),
    );
  }
}
