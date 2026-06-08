import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

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
            onPressed: () => AuthService().signOut(),
          ),
        ],
      ),
      body: const Center(child: Text("Halaman Manajemen Warung")),
    );
  }
}
