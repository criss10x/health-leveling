import 'package:flutter/material.dart';

import 'package:health_leveling/design/tokens.dart';

/// LockScreen — overlay yang muncul saat app terkunci dibuka (PRD §6).
/// "App locked — earn coins to unlock" + maskot Ember + countdown kalau unlock aktif.
class LockScreen extends StatefulWidget {
  const LockScreen({super.key, required this.lockedPkg, this.unlockUntilMs = 0});

  final String lockedPkg;
  final int unlockUntilMs; // epoch ms; >0 & >now → tampilkan countdown

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final unlockActive = widget.unlockUntilMs > now;
    final leftMin = unlockActive ? ((widget.unlockUntilMs - now) / 60000).ceil() : 0;

    return Scaffold(
      backgroundColor: Ds.ink,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),
            Center(
              child: Column(
                children: [
                  Text(
                    '🔒', // authored later: ganti dengan asset lock SVG
                    style: TextStyle(fontSize: Ds.fontNumeral * 0.8),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'App locked',
                    style: TextStyle(
                      color: Ds.ivory,
                      fontSize: Ds.fontTitle,
                      fontWeight: FontWeight.w800,
                      fontFamily: Ds.fontBody,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      _pkgName(widget.lockedPkg),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Ds.chrome,
                        fontSize: 14,
                        fontFamily: Ds.fontBody,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (unlockActive) ...[
                    Text(
                      'Unlock active — $leftMin min left',
                      style: TextStyle(
                        color: Ds.teal,
                        fontSize: Ds.fontChip * 0.66,
                        fontWeight: FontWeight.w700,
                        fontFamily: Ds.fontBody,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  // CTA: kembali ke Health Leveling untuk earn coins
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Ds.ember,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(Ds.rPill),
                          ),
                        ),
                        onPressed: () {
                          // android: pop ke MainActivity (kepulangan app)
                          // test/desktop: NOP — divergence didelegasikan ke host
                          Navigator.of(context, rootNavigator: true).maybePop();
                        },
                        child: Text(
                          'Earn coins in Health Leveling',
                          style: TextStyle(
                            fontSize: Ds.fontCta * 0.62,
                            fontWeight: FontWeight.w700,
                            fontFamily: Ds.fontBody,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(flex: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Text(
                'Do the healthy thing. Then scroll.',
                style: TextStyle(
                  color: Ds.chrome,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontFamily: Ds.fontBody,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Tampilkan nama app yang manusiawi (tanpa package id mentah).
  String _pkgName(String pkg) {
    if (pkg.isEmpty) return 'This app';
    // strip package path untuk short name (v1: tanpa PackageManager label)
    final parts = pkg.split('.');
    return parts.isEmpty ? pkg : parts.last;
  }
}
