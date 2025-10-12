import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const VolleyApp());
}

class VolleyApp extends StatelessWidget {
  const VolleyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Volleyball Position Lottery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> allPlayers = [
    "Kasi",
    "Lingen",
    "Aaron",
    "Alex",
    "Ben",
    "Clemens",
    "Maxi",
    "Daniel",
    "David",
    "Frank",
    "Henning",
    "Leon",
    "Luca",
    "Patrick",
    "Julian",
    "Chris",
    "Linus",
    "Chris",
    "Domme",
    "Joshua",
    "Lukas",
  ];

  Map<String, bool> present = {};
  List<String> selectedLiberos = [];
  Map<int, String> positions = {};
  String? chosenSetter;

  @override
  void initState() {
    super.initState();
    for (var p in allPlayers) {
      present[p] = true;
    }
  }

  void toggleLibero(String name) {
    setState(() {
      if (selectedLiberos.contains(name)) {
        selectedLiberos.remove(name);
      } else {
        selectedLiberos.add(name);
      }
    });
  }

  void drawPositions() {
    List<String> available = present.entries
        .where((e) => e.value && !selectedLiberos.contains(e.key))
        .map((e) => e.key)
        .toList();

    if (available.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Mindestens 6 Spieler (ohne Libero) müssen anwesend sein.",
          ),
        ),
      );
      return;
    }

    available.shuffle(Random());
    List<String> drawn = available.take(6).toList();

    positions = {
      1: drawn[0],
      2: drawn[1],
      3: drawn[2],
      4: drawn[3],
      5: drawn[4],
      6: drawn[5],
    };

    chosenSetter = null; // Reset beim Neulosen
    setState(() {});
  }

  void selectSetter(String name) {
    setState(() {
      chosenSetter = name;
    });
  }

  /// Rollen dynamisch abhängig von Zuspieler-Position
  String getRoleForPosition(int pos) {
    if (chosenSetter == null) return "?";

    int setterPos = positions.entries
        .firstWhere((e) => e.value == chosenSetter)
        .key;

    if (pos == setterPos) return "Zuspieler";

    // Definierte Verteilung je nach Zuspieler
    Map<int, List<int>> aussen = {
      1: [2, 5],
      2: [3, 6],
      3: [4, 1],
      4: [5, 2],
      5: [6, 3],
      6: [1, 4],
    };

    Map<int, List<int>> mitte = {
      1: [3, 6],
      2: [4, 1],
      3: [2, 5],
      4: [6, 3],
      5: [1, 4],
      6: [2, 5],
    };

    Map<int, int> dia = {1: 4, 2: 5, 3: 6, 4: 1, 5: 2, 6: 3};

    if (aussen[setterPos]!.contains(pos)) return "Aussen";
    if (mitte[setterPos]!.contains(pos)) return "Mitte";
    if (dia[setterPos] == pos) return "Diagonal";

    return "?";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Volleyball Position Lottery")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Anwesende Spieler",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 4,
              children: allPlayers.map((p) {
                return FilterChip(
                  label: Text(p),
                  selected: present[p]!,
                  onSelected: (v) => setState(() => present[p] = v),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              "Libero(s) auswählen",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Wrap(
              spacing: 10,
              runSpacing: 4,
              children: allPlayers
                  .where((p) => present[p] == true)
                  .map(
                    (p) => FilterChip(
                      label: Text(p),
                      selected: selectedLiberos.contains(p),
                      onSelected: (_) => toggleLibero(p),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: drawPositions,
              icon: const Icon(Icons.shuffle),
              label: const Text("Positionen losen"),
            ),
            const SizedBox(height: 30),
            if (positions.isNotEmpty) _buildCourt(),
          ],
        ),
      ),
    );
  }

  Widget _buildCourt() {
    return Column(
      children: [
        const Text(
          "Feldaufstellung",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        const SizedBox(height: 10),
        AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.lightBlue[300],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Stack(
                  children: [
                    // Netz-Linie unter den unteren drei (2,3,4)
                    Positioned(
                      bottom: 100,
                      left: 0,
                      right: 0,
                      child: Container(height: 4, color: Colors.white),
                    ),
                    ..._buildPositionWidgets(constraints),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Text(
          chosenSetter == null
              ? "Zuspieler: noch nicht gewählt"
              : "Zuspieler: $chosenSetter",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Text(
          "Libero(s): ${selectedLiberos.join(', ')}",
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  List<Widget> _buildPositionWidgets(BoxConstraints constraints) {
    final double w = constraints.maxWidth;
    final double h = constraints.maxHeight;

    final Map<int, Offset> coords = {
      5: Offset(0.8 * w, 0.15 * h), // oben rechts
      2: Offset(0.2 * w, 0.5 * h), // unten links
      3: Offset(0.5 * w, 0.5 * h), // unten mitte
      4: Offset(0.8 * w, 0.5 * h), // unten rechts
      1: Offset(0.2 * w, 0.15 * h), // oben links
      6: Offset(0.5 * w, 0.15 * h), // oben mitte
    };

    return positions.entries.map((e) {
      final pos = e.key;
      final player = e.value;
      final isSetter = player == chosenSetter;
      final role = getRoleForPosition(pos);

      return Positioned(
        left: coords[pos]!.dx - 30,
        top: coords[pos]!.dy - 30,
        child: GestureDetector(
          onTap: () {
            if (chosenSetter == null) selectSetter(player);
          },
          child: Column(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: isSetter ? Colors.grey[600] : Colors.grey[300],
                child: Text(
                  player[0],
                  style: const TextStyle(color: Colors.black87, fontSize: 18),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$role\n($player)",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87, fontSize: 15),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
