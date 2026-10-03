import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design/tokens.dart';
import 'features/home/home_screen.dart';
import 'features/lock/lock_screen.dart';
import 'services/platform_bridge.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const HealthLevelingApp());
}

class HealthLevelingApp extends StatefulWidget {
  const HealthLevelingApp({super.key});

  @override
  State<HealthLevelingApp> createState() => _HealthLevelingAppState();
}

class _HealthLevelingAppState extends State<HealthLevelingApp> {
  String? _initialLockedPkg;
  final int _unlockUntilMs = 0; // v1: dibaca via LockScreen sendiri belakangan (v2 registri live)

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  /// Miller waktu buka-app: kalau ada locked_pkg dari intent (dari
  /// LockoutAccessibilityService), arahkan ke LockScreen.
  Future<void> _bootstrap() async {
    final pkg = await PlatformBridge.lockedPkg();
    if (!mounted || pkg == null || pkg.isEmpty) return;
    // Cek apakah masih unlock aktif? Registry Flutter stateless — cukup tampilkan
    // LockScreen; bisa jadi unlock kedaluwarsa (unlockActive=false di layar).
    setState(() => _initialLockedPkg = pkg);
    await PlatformBridge.clearLockedPkg();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Leveling',
      debugShowCheckedModeBanner: false,
      navigatorKey: _navKey,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Ds.ink,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Ds.ember,
          primary: Ds.ember,
          secondary: Ds.teal,
          surface: Ds.ink,
        ),
        fontFamily: Ds.fontBody,
      ),
      home: _initialLockedPkg != null
          ? LockScreen(lockedPkg: _initialLockedPkg!, unlockUntilMs: _unlockUntilMs)
          : const HomeScreen(),
    );
  }
}

final GlobalKey<NavigatorState> _navKey = GlobalKey<NavigatorState>();

/// Hanya untuk test — expose navigator key tanpa bikin internal publik.
// ignore: unused_element
NavigatorState? get _testNav => _navKey.currentState;
