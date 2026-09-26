import 'package:flutter/material.dart';
import 'package:health_leveling/design/tokens.dart';

/// Ember Meter home screen — reproduction of approved Comp A
/// (.impeccable/mocks/home-a.png) per .impeccable/build/spec.json regions.
///
/// Layout uses a fixed 576×1024 design canvas scaled to the screen
/// (LayoutBuilder + FittedBox-style scaling) so region geometry from the
/// comp spec maps 1:1.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const double canvasW = 576;
  static const double canvasH = 1024;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Ds.ink,
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final scale = constraints.maxWidth / canvasW;
            return FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: canvasW,
                height: canvasH,
                child: Transform.scale(
                  scale: scale,
                  child: const _Canvas(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Canvas extends StatelessWidget {
  const _Canvas();

  // Region geometry from .impeccable/build/spec.json (px on 576×1024 canvas)
  static const _coinChip = Rect.fromLTWH(40, 150, 180, 56);
  static const _coinNumeral = Rect.fromLTWH(340, 130, 200, 80);
  static const _gaugePlate = Rect.fromLTWH(195, 150, 190, 330);
  static const _challengeCard = Rect.fromLTWH(52, 560, 472, 80);
  static const _progressBar = Rect.fromLTWH(52, 690, 472, 12);
  static const _ctaStart = Rect.fromLTWH(52, 760, 472, 60);
  static const _bottomNav = Rect.fromLTWH(0, 924, 576, 100);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: HomeScreen.canvasW,
      height: HomeScreen.canvasH,
      color: Ds.ink,
      child: Stack(
        children: [
          // gauge ring
          const Positioned(left: 46, top: 143, width: 484, height: 484, child: _GaugeRing()),
          // coin chip (teal pill, upper-left over ring)
          Positioned.fromRect(
            rect: _coinChip,
            child: _CoinChip(text: '1,240 coins'),
          ),
          // coin numeral (upper-right)
          Positioned.fromRect(
            rect: _coinNumeral,
            child: const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '1,240',
                style: TextStyle(
                  color: Color(0xFFF8F8EF),
                  fontSize: Ds.fontNumeral,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
            ),
          ),
          // mascot plate
          Positioned.fromRect(
            rect: _gaugePlate,
            child: Image.asset('assets/plates/gauge-plate.png', fit: BoxFit.contain),
          ),
          // challenge card
          Positioned.fromRect(
            rect: _challengeCard,
            child: Container(
              decoration: BoxDecoration(
                color: Ds.cardBg,
                borderRadius: BorderRadius.circular(Ds.rCard),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Day 4 · Fitness Starter',
                style: TextStyle(color: Ds.ink, fontSize: 24, fontWeight: FontWeight.w400),
              ),
            ),
          ),
          // progress bar
          Positioned.fromRect(
            rect: _progressBar,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  Container(color: Ds.barTrack),
                  FractionallySizedBox(
                    widthFactor: 0.35,
                    child: Container(color: Ds.teal),
                  ),
                ],
              ),
            ),
          ),
          // CTA
          Positioned.fromRect(
            rect: _ctaStart,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Ds.ember,
                borderRadius: BorderRadius.circular(Ds.rPill),
              ),
              child: const Center(
                child: Text(
                  'Start session',
                  style: TextStyle(color: Colors.white, fontSize: Ds.fontCta, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          // bottom nav
          Positioned.fromRect(rect: _bottomNav, child: const _BottomNav()),
        ],
      ),
    );
  }
}

class _GaugeRing extends StatelessWidget {
  const _GaugeRing();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GaugePainter());
  }
}

class _GaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    const stroke = 14.0;

    // tick marks (12 around)
    final tick = Paint()
      ..color = const Color(0xFFE0B899)
      ..strokeWidth = 1.6;
    for (var i = 0; i < 12; i++) {
      final a = i * 30 * 3.14159265 / 180;
      final p1 = center + Offset.fromDirection(a, radius + 8);
      final p2 = center + Offset.fromDirection(a, radius + 14);
      canvas.drawLine(p1, p2, tick);
    }

    // track
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = Ds.emberSoft;
    canvas.drawCircle(center, radius, track);

    // progress arc 70%
    const start = -90 * 3.14159265 / 180;
    const sweep = 0.70 * 2 * 3.14159265;
    final arc = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = Ds.ember;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), start, sweep, false, arc);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CoinChip extends StatelessWidget {
  const _CoinChip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Ds.teal,
        borderRadius: BorderRadius.circular(28),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: Ds.fontChip, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Ds.navBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const Icon(Icons.home_rounded, size: 30, color: Ds.teal),
          Container(
            width: 64,
            height: 64,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: const BoxDecoration(color: Ds.ink, shape: BoxShape.circle),
            child: const Icon(Icons.add, size: 32, color: Colors.white),
          ),
          const Icon(Icons.lock_outline_rounded, size: 30, color: Ds.chrome),
        ],
      ),
    );
  }
}
