import 'package:flutter/material.dart';
import 'dart:math';

class PositionstreueLosenScreen extends StatefulWidget {
  const PositionstreueLosenScreen({super.key});

  @override
  State<PositionstreueLosenScreen> createState() =>
      _PositionstreueLosenScreenState();
}

class _PositionstreueLosenScreenState extends State<PositionstreueLosenScreen> {
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
    "Domme",
    "Lukas",
    "Zusatzspieler:in 1",
    "Zusatzspieler:in 2",
    "Zusatzspilerin:in 3",
  ];

  final Map<String, List<String>> playerPositions =
      {}; // Spieler → Liste von Positionen
  Map<String, int> finalPositions = {}; // Spieler → Feldnummer

  void togglePosition(String player, String position) {
    setState(() {
      playerPositions.putIfAbsent(player, () => []);
      if (playerPositions[player]!.contains(position)) {
        playerPositions[player]!.remove(position);
      } else {
        playerPositions[player]!.add(position);
      }
    });
  }

  void losen() {
    final rng = Random();
    final Map<int, String> assigned = {};

    // Slots
    final Map<String, List<int>> slots = {
      'Z': [1],
      'M': [3, 6],
      'D': [4],
      'AA': [2, 5],
    };

    List<String> remainingPlayers = List.from(allPlayers)..shuffle(rng);

    // Pritscher
    final zPlayers = remainingPlayers
        .where((p) => playerPositions[p]?.contains('Z') ?? false)
        .toList();
    if (zPlayers.isNotEmpty) {
      assigned[1] = zPlayers[rng.nextInt(zPlayers.length)];
      remainingPlayers.remove(assigned[1]);
    }

    //  Mitte
    final mPlayers = remainingPlayers
        .where((p) => playerPositions[p]?.contains('M') ?? false)
        .toList();
    final mSlots = [3, 6];
    for (var slot in mSlots) {
      if (mPlayers.isEmpty) break;
      final player = mPlayers.removeAt(rng.nextInt(mPlayers.length));
      assigned[slot] = player;
      remainingPlayers.remove(player);
    }

    //  Diagonal
    final dPlayers = remainingPlayers
        .where((p) => playerPositions[p]?.contains('D') ?? false)
        .toList();
    if (dPlayers.isNotEmpty) {
      assigned[4] = dPlayers[rng.nextInt(dPlayers.length)];
      remainingPlayers.remove(assigned[4]);
    }

    // Außen
    final aaPlayers = remainingPlayers
        .where((p) => playerPositions[p]?.contains('AA') ?? false)
        .toList();
    final aaSlots = [2, 5];
    for (var slot in aaSlots) {
      if (aaPlayers.isEmpty) break;
      final player = aaPlayers.removeAt(rng.nextInt(aaPlayers.length));
      assigned[slot] = player;
      remainingPlayers.remove(player);
    }

    // Slots füllen, falls noch frei (optional)
    for (var slot in [1, 2, 3, 4, 5, 6]) {
      if (!assigned.containsKey(slot) && remainingPlayers.isNotEmpty) {
        assigned[slot] = remainingPlayers.removeAt(0);
      }
    }

    //  Libero
    final liberos = playerPositions.entries
        .where((e) => e.value.contains('Libero'))
        .map((e) => e.key)
        .toList();

    String? chosenLibero;
    if (liberos.isNotEmpty) {
      liberos.shuffle(rng);
      chosenLibero = liberos.first;
    }

    setState(() {
      finalPositions = {
        for (var e in assigned.entries) e.value: e.key,
        if (chosenLibero != null) chosenLibero: 0,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Positionstreue Losen"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: allPlayers.length,
              itemBuilder: (context, index) {
                final player = allPlayers[index];
                final selected = playerPositions[player] ?? [];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: ExpansionTile(
                    title: Text(player),
                    subtitle: Text(
                      selected.isEmpty
                          ? "Keine Position gewählt"
                          : "Positionen: ${selected.join(', ')}",
                    ),
                    children: [
                      Wrap(
                        spacing: 8,
                        children: [
                          for (final pos in ["Z", "AA", "M", "D", "Libero"])
                            FilterChip(
                              label: Text(pos),
                              selected: selected.contains(pos),
                              onSelected: (_) => togglePosition(player, pos),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: losen,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            ),
            child: const Text("Los!"),
          ),
          const SizedBox(height: 12),
          if (finalPositions.isNotEmpty)
            Expanded(
              child: ListView(
                children: finalPositions.entries.map((e) {
                  final pos = e.value;
                  final posText = pos == 0 ? "Libero" : "Position $pos";
                  return ListTile(title: Text(e.key), trailing: Text(posText));
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
