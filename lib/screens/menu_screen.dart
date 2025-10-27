import 'package:flutter/material.dart';
import 'untreues_losen_screen.dart';
import 'treues_losen_screen.dart';
import 'zufallsrad_screen.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Volleyball Tools")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UntreuesLosenScreen()),
              ),
              child: const Text("Positions-untreues Losen"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PositionstreueLosenScreen(),
                ),
              ),
              child: const Text("Positions-treues Losen"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GluecksradScreen()),
              ),
              child: const Text("Strafenrad"),
            ),
          ],
        ),
      ),
    );
  }
}
