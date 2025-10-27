import 'dart:math';
import 'package:flutter/material.dart';

///  Screen, wo man Namen eingibt und dann "Positions-untreu" losen kann
class UntreuesLosenScreen extends StatefulWidget {
  const UntreuesLosenScreen({super.key});

  @override
  State<UntreuesLosenScreen> createState() => _UntreuesLosenScreenState();
}

class _UntreuesLosenScreenState extends State<UntreuesLosenScreen> {
  final TextEditingController controller = TextEditingController();
  List<String> players = [];

  void addPlayer() {
    final name = controller.text.trim();
    if (name.isNotEmpty && !players.contains(name)) {
      setState(() {
        players.add(name);
        controller.clear();
      });
    }
  }

  void removePlayer(String name) {
    setState(() => players.remove(name));
  }

  void startDraw() {
    if (players.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mindestens 6 Spieler nötig.")),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen(customPlayers: players)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Positions-untreues Losen")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: "Spielername eingeben",
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: addPlayer,
                ),
              ),
              onSubmitted: (_) => addPlayer(),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: players
                    .map(
                      (p) => ListTile(
                        title: Text(p),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => removePlayer(p),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            ElevatedButton.icon(
              onPressed: startDraw,
              icon: const Icon(Icons.play_arrow),
              label: const Text("Starten"),
            ),
          ],
        ),
      ),
    );
  }
}

/// Losen ohne Positionstreue
class HomeScreen extends StatefulWidget {
  final List<String>? customPlayers;
  const HomeScreen({super.key, this.customPlayers});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<String> allPlayers;
  Map<String, bool> present = {};
  List<String> selectedLiberos = [];
  Map<int, String> positions = {};
  String? chosenSetter;

  @override
  void initState() {
    super.initState();

    // Wenn customPlayers gesetzt ist → nimm die, sonst Standardliste
    allPlayers =
        widget.customPlayers ??
        [
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
          "Mark",
        ];

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

    chosenSetter = null;
    setState(() {});
  }

  void selectSetter(String name) {
    setState(() {
      chosenSetter = name;
    });
  }

  String getRoleForPosition(int pos) {
    if (chosenSetter == null) return "?";

    int setterPos = positions.entries
        .firstWhere((e) => e.value == chosenSetter)
        .key;

    if (pos == setterPos) return "Zuspieler";

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

  List _buildPositionWidgets(BoxConstraints constraints) {
    final double w = constraints.maxWidth;
    final double h = constraints.maxHeight;

    final Map<int, Offset> coords = {
      5: Offset(0.8 * w, 0.15 * h),
      2: Offset(0.2 * w, 0.5 * h),
      3: Offset(0.5 * w, 0.5 * h),
      4: Offset(0.8 * w, 0.5 * h),
      1: Offset(0.2 * w, 0.15 * h),
      6: Offset(0.5 * w, 0.15 * h),
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
