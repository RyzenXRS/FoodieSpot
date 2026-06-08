import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _selectedRole = 'user';
  bool _isLoading = false;

  // --- Fungsi untuk memunculkan notifikasi di atas ---
  void _showTopNotification(String message, Color color) {
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
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 140,
          left: 16,
          right: 16,
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // --- Fungsi Register yang sudah diupdate ---
  void _register() async {
    setState(() => _isLoading = true);
    try {
      await AuthService().registerUser(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        role: _selectedRole,
      );

      // Munculkan notifikasi sukses
      if (mounted) {
        _showTopNotification(
          "Registrasi berhasil! Membuka halaman utama...",
          Colors.green,
        );
        // Navigator.pop(context) tidak perlu lagi karena RoleChecker akan otomatis menarik kita ke Home
      }
    } catch (e) {
      if (mounted) {
        _showTopNotification("Gagal Register: ${e.toString()}", Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register FoodieSpot")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              items: const [
                DropdownMenuItem(
                  value: 'user',
                  child: Text('User / Pengunjung'),
                ),
                DropdownMenuItem(value: 'owner', child: Text('Owner Warung')),
              ],
              onChanged: (val) => setState(() => _selectedRole = val!),
              decoration: const InputDecoration(labelText: 'Daftar Sebagai'),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: const Text("Register"),
                  ),
          ],
        ),
      ),
    );
  }
}
