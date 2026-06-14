import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/tempat_makan_service.dart';
import '../../services/pengajuan_owner.dart';
import '../../models/tempat_makan_model.dart';
import '../../models/user_model.dart';
import '../../models/pengajuan_owner_model.dart';
import '../profile/profile_page.dart';
import '../tempat_makan/detail_tempat_makan_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  late Future<List<TempatMakanModel>> _tempatMakanFuture;
  PengajuanOwnerModel? _pengajuan;
  bool _isLoadingPengajuan = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _fetchStatusPengajuan();
  }

  void _fetchData() {
    setState(() {
      _tempatMakanFuture = TempatMakanService().getTempatMakan();
    });
  }

  void _fetchStatusPengajuan() async {
    setState(() => _isLoadingPengajuan = true);
    try {
      final data = await PengajuanOwnerService().cekStatus();
      if (mounted) setState(() => _pengajuan = data);
    } catch (e) {
      // Abaikan jika belum ada pengajuan
    } finally {
      if (mounted) setState(() => _isLoadingPengajuan = false);
    }
  }

  // --- MODAL PENGAJUAN (Bisa untuk Daftar & Lihat Status) ---
  void _showMitraModal() {
    final namaTokoCtrl = TextEditingController();
    final deskripsiTokoCtrl = TextEditingController();
    final alamatCtrl = TextEditingController();
    File? selectedKtp;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_pengajuan == null) ...[
                    const Text(
                      "Formulir Kemitraan Owner",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: namaTokoCtrl,
                      decoration: const InputDecoration(
                        labelText: "Nama Tempat Makan",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: alamatCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Alamat Lengkap",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: deskripsiTokoCtrl,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Deskripsi Singkat",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // --- AREA UPLOAD KTP ---
                    const Text(
                      "Upload Kartu Identitas (KTP)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                          imageQuality: 70,
                        );
                        if (pickedFile != null) {
                          setModalState(
                            () => selectedKtp = File(pickedFile.path),
                          );
                        }
                      },
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey[400]!),
                        ),
                        child: selectedKtp != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  selectedKtp!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.credit_card,
                                    color: Colors.grey,
                                    size: 32,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Pilih Foto KTP",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    isSubmitting
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              if (namaTokoCtrl.text.isEmpty ||
                                  deskripsiTokoCtrl.text.isEmpty ||
                                  alamatCtrl.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Semua kolom teks wajib diisi!",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              if (selectedKtp == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Foto KTP wajib diunggah!"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              setModalState(() => isSubmitting = true);
                              try {
                                await PengajuanOwnerService().ajukan(
                                  namaTokoCtrl.text.trim(),
                                  deskripsiTokoCtrl.text.trim(),
                                  alamatCtrl.text.trim(),
                                  selectedKtp!,
                                );
                                if (mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Pengajuan beserta KTP berhasil dikirim!",
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  _fetchStatusPengajuan();
                                }
                              } catch (e) {
                                if (mounted)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().replaceAll(
                                          "Exception: ",
                                          "",
                                        ),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                              } finally {
                                if (mounted)
                                  setModalState(() => isSubmitting = false);
                              }
                            },
                            child: const Text(
                              "Kirim Pengajuan",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ] else ...[
                    // Bagian Status Pending tetap sama...
                    const Icon(
                      Icons.access_time_filled,
                      color: Colors.blue,
                      size: 60,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Pengajuan Diproses",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Toko '${_pengajuan!.namaToko}' sedang direview oleh Admin. Mohon bersabar ya!",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    isSubmitting
                        ? const Center(child: CircularProgressIndicator())
                        : OutlinedButton(
                            onPressed: () async {
                              setModalState(() => isSubmitting = true);
                              try {
                                await PengajuanOwnerService().batalkan();
                                if (mounted) {
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Pengajuan dibatalkan"),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  _fetchStatusPengajuan();
                                }
                              } catch (e) {
                                if (mounted)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        e.toString().replaceAll(
                                          "Exception: ",
                                          "",
                                        ),
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                              } finally {
                                if (mounted)
                                  setModalState(() => isSubmitting = false);
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.red),
                              foregroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text("Batalkan Pengajuan"),
                          ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cari Kuliner"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        actions: [
          // --- TOMBOL JADI MITRA YANG MENCURI PERHATIAN ---
          if (!_isLoadingPengajuan)
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 4.0,
              ),
              child: ElevatedButton.icon(
                onPressed: _showMitraModal,
                icon: Icon(
                  _pengajuan == null ? Icons.storefront : Icons.hourglass_top,
                  size: 16,
                ),
                label: Text(
                  _pengajuan == null ? "Jadi Mitra" : "Pending",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _pengajuan == null
                      ? Colors.white
                      : Colors
                            .blue[50], // Putih jika belum, Biru muda jika pending
                  foregroundColor: _pengajuan == null
                      ? Colors.orange
                      : Colors.blue, // Teks orange jika belum
                  elevation: 1,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              ),
            ),

          // Tombol Profil
          IconButton(
            icon: const Icon(Icons.account_circle, size: 28),
            onPressed: () async {
              UserModel? currentUser = await AuthService().getCurrentUser();
              if (currentUser != null && context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfilePage(user: currentUser),
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 8), // Sedikit jarak dari pinggir layar
        ],
      ),
      body: FutureBuilder<List<TempatMakanModel>>(
        future: _tempatMakanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text("Gagal memuat data: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.isEmpty)
            return const Center(child: Text("Belum ada tempat makan."));

          final listTempat = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _fetchData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: listTempat.length,
              itemBuilder: (context, index) {
                final item = listTempat[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DetailTempatMakanPage(tempatMakan: item),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 140,
                          width: double.infinity,
                          color: Colors.orange[200],
                          child: const Icon(
                            Icons.fastfood,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 16,
                                    color: Colors.amber,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item.rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    size: 16,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      item.address,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
