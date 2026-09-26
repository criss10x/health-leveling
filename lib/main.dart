import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design/tokens.dart';
import 'features/home/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const HealthLevelingApp());
}

class HealthLevelingApp extends StatelessWidget {
  const HealthLevelingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Leveling',
      debugShowCheckedModeBanner: false,
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
      home: const HomeScreen(),
    );
  }
}
