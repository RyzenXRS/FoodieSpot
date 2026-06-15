import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'register_page.dart';
import '../splash/role_checker.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  // --- Fungsi untuk memunculkan notifikasi di atas ---
  void _showTopNotification(String message, Color color) {
    // Tutup keyboard terlebih dahulu agar posisi layar kembali normal
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        // Mendorong notifikasi ke atas sejauh tinggi layar dikurangi 140 pixel
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 140,
          left: 16,
          right: 16,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- Fungsi Login yang sudah diupdate ---
  void _login() async {
    setState(() => _isLoading = true);
    try {
      await AuthService().loginUser(_emailCtrl.text.trim(), _passwordCtrl.text);

      if (!mounted) return;

      // Letakkan ini setelah notifikasi sukses dimunculkan
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const RoleChecker()),
        (route) => false,
      );

      // Munculkan notifikasi sukses
      if (mounted) {
        _showTopNotification(
          "Login berhasil! Selamat datang kembali.",
          Colors.green,
        );
      }
      // Pindah halaman otomatis di-handle oleh RoleChecker
    } catch (e) {
      if (mounted) {
        _showTopNotification(
          "Gagal Login: Email atau password salah",
          Colors.red,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login FoodieSpot")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordCtrl,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: _login, child: const Text("Login")),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              },
              child: const Text("Belum punya akun? Register"),
            ),
          ],
        ),
      ),
    );
  }
}
