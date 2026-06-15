import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../splash/role_checker.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;
  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  bool _isEditing = false;
  bool _isLoading = false;
  File? _selectedPhoto;

  // Menyimpan data user terkini agar foto bisa langsung update setelah simpan
  late UserModel _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    _nameCtrl = TextEditingController(text: widget.user.name);
    _phoneCtrl = TextEditingController(text: widget.user.phone);
  }

  String _resolveImageUrl(String url) {
    if (url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    // Fallback: bangun URL manual jika belum full URL
    const rootUrl = 'http://10.0.2.2:8000';
    return '$rootUrl/storage/$url';
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 60,
    );
    if (pickedFile != null) {
      setState(() => _selectedPhoto = File(pickedFile.path));
    }
  }

  void _showTopNotification(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  void _handleUpdate() async {
    if (_nameCtrl.text.isEmpty) {
      _showTopNotification('Nama tidak boleh kosong!', Colors.red);
      return;
    }
    setState(() => _isLoading = true);
    try {
      final updatedUser = await AuthService().updateProfile(
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        photoFile: _selectedPhoto,
      );
      if (!mounted) return;
      setState(() {
        _currentUser = updatedUser;
        _selectedPhoto = null;
        _isEditing = false;
      });
      _showTopNotification('Profil berhasil diperbarui!', Colors.green);
    } catch (e) {
      if (!mounted) return;
      _showTopNotification(
        e.toString().replaceAll('Exception: ', ''),
        Colors.red,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Akun Permanen?'),
        content: const Text(
          'Tindakan ini tidak bisa dibatalkan. Semua data Anda akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isLoading = true);
              try {
                await AuthService().deleteAccount();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const RoleChecker()),
                  (route) => false,
                );
              } catch (e) {
                if (!mounted) return;
                _showTopNotification(e.toString(), Colors.red);
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    // Prioritas: foto baru yang belum disimpan > foto dari server > ikon default
    if (_selectedPhoto != null) {
      return CircleAvatar(
        radius: 55,
        backgroundImage: FileImage(_selectedPhoto!),
      );
    }
    if (_currentUser.photoUrl.isNotEmpty) {
      final url = _resolveImageUrl(_currentUser.photoUrl);
      return CircleAvatar(
        radius: 55,
        backgroundColor: Colors.orange[100],
        backgroundImage: NetworkImage(url),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }
    return CircleAvatar(
      radius: 55,
      backgroundColor: Colors.orange,
      child: Text(
        _currentUser.name.isNotEmpty ? _currentUser.name[0].toUpperCase() : 'U',
        style: const TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // --- FOTO PROFIL ---
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      _buildAvatar(),
                      // Tombol ganti foto, hanya aktif saat mode edit
                      if (_isEditing)
                        GestureDetector(
                          onTap: _pickPhoto,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            padding: const EdgeInsets.all(6),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (_isEditing)
                    TextButton(
                      onPressed: _pickPhoto,
                      child: const Text(
                        'Ganti Foto Profil',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),

                  const SizedBox(height: 8),
                  Text(
                    _currentUser.email,
                    style: const TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Chip(
                    label: Text(
                      _currentUser.role.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    backgroundColor: Colors.orange[50],
                    side: BorderSide.none,
                  ),
                  const SizedBox(height: 24),

                  // --- FORM NAMA & TELEPON ---
                  TextField(
                    controller: _nameCtrl,
                    enabled: _isEditing,
                    decoration: const InputDecoration(
                      labelText: 'Nama Lengkap',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneCtrl,
                    enabled: _isEditing,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Telepon',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- TOMBOL AKSI ---
                  if (!_isEditing) ...[
                    ElevatedButton.icon(
                      onPressed: () => setState(() => _isEditing = true),
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Profil'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _confirmDeleteAccount,
                      icon: const Icon(Icons.delete_forever, color: Colors.red),
                      label: const Text(
                        'Hapus Akun',
                        style: TextStyle(color: Colors.red),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await AuthService().signOut();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const RoleChecker()),
                          (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.grey),
                      label: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.grey),
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        side: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: _handleUpdate,
                      icon: const Icon(Icons.save),
                      label: const Text('Simpan Perubahan'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        _nameCtrl.text = _currentUser.name;
                        _phoneCtrl.text = _currentUser.phone;
                        setState(() {
                          _isEditing = false;
                          _selectedPhoto = null;
                        });
                      },
                      child: const Text(
                        'Batal',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
