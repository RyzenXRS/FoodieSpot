import 'dart:io'; // WAJIB TAMBAHKAN INI
import 'package:flutter/material.dart';
import 'ui/splash/role_checker.dart';

// --- TAMBAHKAN CLASS INI UNTUK BYPASS SSL LOKAL ---
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- AKTIFKAN BYPASS SSL ---
  HttpOverrides.global = MyHttpOverrides();

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
