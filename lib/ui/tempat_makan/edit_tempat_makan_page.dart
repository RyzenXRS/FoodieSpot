import 'package:flutter/material.dart';
import '../../models/tempat_makan_model.dart';
import '../../services/tempat_makan_service.dart';

class EditTempatMakanPage extends StatefulWidget {
  final TempatMakanModel tempatMakan; // Menerima data yang mau diedit

  const EditTempatMakanPage({super.key, required this.tempatMakan});

  @override
  State<EditTempatMakanPage> createState() => _EditTempatMakanPageState();
}

class _EditTempatMakanPageState extends State<EditTempatMakanPage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _addressCtrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Isi form dengan data yang sudah ada
    _nameCtrl = TextEditingController(text: widget.tempatMakan.name);
    _descCtrl = TextEditingController(text: widget.tempatMakan.description);
    _addressCtrl = TextEditingController(text: widget.tempatMakan.address);
  }

  void _submit() async {
    if (_nameCtrl.text.isEmpty ||
        _descCtrl.text.isEmpty ||
        _addressCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua kolom wajib diisi!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await TempatMakanService().updateTempatMakan(
        id: widget.tempatMakan.id, // Kirim ID tempat makan
        name: _nameCtrl.text.trim(),
        desc: _descCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Tempat makan berhasil diperbarui!"),
            backgroundColor: Colors.blue,
          ),
        );
        Navigator.pop(context, true); // Kembali ke dashboard dengan nilai true
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Tempat Makan")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Tempat Makan',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Deskripsi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _addressCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Alamat Lengkap',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      "Simpan Perubahan",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
