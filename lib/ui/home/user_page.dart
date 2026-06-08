import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../splash/role_checker.dart'; // WAJIB TAMBAH INI agar RoleChecker tidak error

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home - User"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const RoleChecker()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: const Center(child: Text("Halaman Cari Kuliner")),
    );
  }
}
