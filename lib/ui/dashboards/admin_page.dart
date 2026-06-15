import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../models/pengajuan_owner_model.dart';
import '../splash/role_checker.dart';
import '../../utils/constants.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  late Future<List<PengajuanOwnerModel>> _pengajuanFuture;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _pengajuanFuture = AdminService().getPendingPengajuan();
    });
  }

  String _buildImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    String rootUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    return '$rootUrl/storage/$path';
  }

  void _showDetailModal(PengajuanOwnerModel item) {
    bool isProcessing = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.9, // Modal setinggi 90% layar
              minChildSize: 0.5,
              maxChildSize: 0.95,
              expand: false,
              builder: (_, controller) => Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Detail Pengajuan Mitra",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 32, thickness: 1),

                    Expanded(
                      child: ListView(
                        controller: controller,
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.person, color: Colors.white),
                            ),
                            title: Text(
                              item.userName ?? 'User',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(item.userEmail ?? ''),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "Data Toko",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.namaToko,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 18,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  item.alamat ?? 'Alamat tidak diisi',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            "Deskripsi:",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(item.deskripsiToko),
                          const SizedBox(height: 24),

                          // --- FOTO KTP ---
                          const Text(
                            "Dokumen KTP:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (item.ktpPath != null && item.ktpPath!.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                _buildImageUrl(item.ktpPath),
                                fit: BoxFit.cover,
                              ),
                            )
                          else
                            Container(
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text("KTP tidak dilampirkan"),
                              ),
                            ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),

                    // --- TOMBOL AKSI (TOLAK / SETUJUI) ---
                    if (isProcessing)
                      const Center(child: CircularProgressIndicator())
                    else
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () async {
                                setModalState(() => isProcessing = true);
                                try {
                                  await AdminService().rejectPengajuan(item.id);
                                  if (!ctx.mounted || !mounted) return;
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Pengajuan ditolak."),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  _fetchData();
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  setModalState(() => isProcessing = false);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: const BorderSide(color: Colors.red),
                                foregroundColor: Colors.red,
                              ),
                              child: const Text(
                                "Tolak",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                setModalState(() => isProcessing = true);
                                try {
                                  await AdminService().approvePengajuan(
                                    item.id,
                                  );
                                  if (!ctx.mounted || !mounted) return;
                                  Navigator.pop(ctx);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Berhasil disetujui! User menjadi Owner.",
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  _fetchData();
                                } catch (e) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(e.toString()),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  setModalState(() => isProcessing = false);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                "SETUJUI",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
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
        title: const Text("Portal Admin"),
        backgroundColor: Colors.blue[900], // Warna khusus admin biar beda
        foregroundColor: Colors.white,
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
      body: FutureBuilder<List<PengajuanOwnerModel>>(
        future: _pengajuanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Tidak ada antrean.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final listPengajuan = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _fetchData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: listPengajuan.length,
              itemBuilder: (context, index) {
                final item = listPengajuan[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.storefront, color: Colors.white),
                    ),
                    title: Text(
                      item.namaToko,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          "Pemohon: ${item.userName}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        Text(
                          "Waktu: Baru saja",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        _showDetailModal(item), // Buka pop-up ACC/Tolak
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
