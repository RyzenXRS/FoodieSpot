import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home - Admin"),
        backgroundColor: Colors.red, // Beda warna untuk admin
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: const Center(child: Text("Dashboard Admin")),
    );
  }
}
