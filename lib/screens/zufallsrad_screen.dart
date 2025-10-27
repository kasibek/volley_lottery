import 'dart:math';
import 'package:flutter/material.dart';

class GluecksradScreen extends StatefulWidget {
  const GluecksradScreen({super.key});

  @override
  State<GluecksradScreen> createState() => _GluecksradScreenState();
}

class _GluecksradScreenState extends State<GluecksradScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Map<String, dynamic>> segments = [
    {'text': 'Keine Strafe', 'weight': 9, 'color': Colors.green},
    {'text': 'Kiste', 'weight': 11, 'color': Colors.red},
    {'text': '5 Linienläufe', 'weight': 10, 'color': Colors.orange},
    {'text': '20 Liegestütz', 'weight': 10, 'color': Colors.blue},
    {'text': '20 Burpees', 'weight': 10, 'color': Colors.purple},
    {'text': 'Kuchen', 'weight': 10, 'color': Colors.yellow},
  ];

  double _currentRotation = 0;
  String? selectedSegment;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  void spinWheel() {
    final rng = Random();

    final totalWeight = segments.fold<int>(
      0,
      (sum, s) => sum + (s['weight'] as int),
    );
    final choice = rng.nextInt(totalWeight);

    int cumulative = 0;
    int chosenIndex = 0;
    for (int i = 0; i < segments.length; i++) {
      cumulative += segments[i]['weight'] as int;
      if (choice < cumulative) {
        chosenIndex = i;
        break;
      }
    }

    // Mehrere volle Drehungen + Zielsegment
    double rotations = 4 + rng.nextDouble() * 2; // 4-6 volle Umdrehungen
    double anglePerSegment = 2 * pi / segments.length;
    double targetAngle =
        (chosenIndex * anglePerSegment) + (anglePerSegment / 2);

    final double startRotation = _currentRotation;
    final double endRotation = startRotation + rotations * 2 * pi + targetAngle;

    _controller.reset();

    _animation =
        Tween<double>(begin: startRotation, end: endRotation).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
          )
          ..addListener(() {
            setState(() {
              _currentRotation = _animation.value;
            });
          })
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              setState(() {
                _currentRotation = endRotation % (2 * pi);
                selectedSegment = segments[chosenIndex]['text'] as String;
              });
            }
          });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget buildLegend() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 6,
      children: segments
          .map(
            (s) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 20, height: 20, color: s['color'] as Color),
                const SizedBox(width: 4),
                Text(s['text'] as String),
              ],
            ),
          )
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Strafenrad")),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            buildLegend(),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.topCenter,
              children: [
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _currentRotation,
                      child: child,
                    );
                  },
                  child: CustomPaint(
                    size: const Size(300, 300),
                    painter: _WheelPainter(segments: segments),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Icon(
                    Icons.arrow_drop_down,
                    size: 40,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: spinWheel,
              child: const Text("Rad drehen!"),
            ),
            const SizedBox(height: 20),
            // hier könnte man unten noch das Ergebnis anzeigen lassen, aber ich habe da noch nen Fehler drin
            // if (selectedSegment != null)
            //   Text(
            //     "Ergebnis: $selectedSegment",
            //     style: const TextStyle(
            //       fontSize: 24,
            //       fontWeight: FontWeight.bold,
            //     ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<Map<String, dynamic>> segments;

  _WheelPainter({required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    final totalWeight = segments.fold<int>(
      0,
      (sum, s) => sum + (s['weight'] as int),
    );

    double startAngle = -pi / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    for (var seg in segments) {
      double sweepAngle = 2 * pi * (seg['weight'] as int) / totalWeight;
      paint.color = seg['color'] as Color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: seg['text'] as String,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      double angle = startAngle + sweepAngle / 2;
      final offset = Offset(
        center.dx + radius * 0.6 * cos(angle) - textPainter.width / 2,
        center.dy + radius * 0.6 * sin(angle) - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
