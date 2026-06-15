import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../auth/login_page.dart';
import '../dashboards/user_page.dart';
import '../dashboards/owner_page.dart';
import '../dashboards/admin_page.dart';

class RoleChecker extends StatelessWidget {
  const RoleChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Cek apakah ada data user yang tersimpan di HP
      future: AuthService().getCurrentUser(),
      builder: (context, snapshot) {
        // Layar loading saat membaca SharedPreferences
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userModel = snapshot.data;

        // 1. Jika tidak ada data user (Belum login), lempar ke LoginPage
        if (userModel == null) {
          return const LoginPage();
        }

        // 2. Jika akun kena suspend, blokir aktivitasnya
        if (userModel.isSuspended) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.block, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  const Text(
                    "Akun Anda telah ditangguhkan.",
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () async {
                      await AuthService().signOut();
                      if (!context.mounted) return;
                      // Refresh halaman setelah logout
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const RoleChecker()),
                        (route) => false,
                      );
                    },
                    child: const Text("Logout"),
                  ),
                ],
              ),
            ),
          );
        }

        // 3. Routing Berdasarkan Role
        switch (userModel.role) {
          case 'owner':
            return const OwnerHomePage();
          case 'admin':
            return const AdminHomePage();
          case 'user':
          default:
            return const UserHomePage();
        }
      },
    );
  }
}
