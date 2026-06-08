import 'package:flutter/material.dart';
import 'ui/splash/role_checker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const FoodieSpotApp());
}

class FoodieSpotApp extends StatelessWidget {
  const FoodieSpotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoodieSpot',
      theme: ThemeData(primarySwatch: Colors.orange, useMaterial3: true),
      home: const RoleChecker(),
      debugShowCheckedModeBanner: false,
    );
  }
}
