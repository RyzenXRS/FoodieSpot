import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../splash/role_checker.dart';

class OwnerHomePage extends StatelessWidget {
  const OwnerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home - Owner"),
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
      body: const Center(child: Text("Halaman Manajemen Warung")),
    );
  }
}
