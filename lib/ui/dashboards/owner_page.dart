import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/tempat_makan_service.dart';
import '../../models/tempat_makan_model.dart';
import '../splash/role_checker.dart';
import '../tempat_makan/add_tempat_makan_page.dart';
import '../tempat_makan/edit_tempat_makan_page.dart'; // <-- IMPORT BARU
import '../tempat_makan/detail_tempat_makan_page.dart'; // <-- IMPORT BARU

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key});

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  late Future<List<TempatMakanModel>> _myTempatMakanFuture;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _myTempatMakanFuture = TempatMakanService().getMyTempatMakan();
    });
  }

  void _konfirmasiHapus(int id, String nama) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Warung?"),
        content: Text(
          "Yakin ingin menutup '$nama' secara permanen? Semua foto dan review juga akan lenyap.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await TempatMakanService().deleteTempatMakan(id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Warung berhasil ditutup."),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  _fetchData();
                }
              } catch (e) {
                if (mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                      backgroundColor: Colors.red,
                    ),
                  );
              }
            },
            child: const Text(
              "Ya, Tutup Warung",
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard Juragan"),
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              if (context.mounted)
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const RoleChecker()),
                  (route) => false,
                );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green[800],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_business),
        label: const Text("Warung Baru"),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTempatMakanPage()),
          );
          if (result == true) _fetchData();
        },
      ),
      body: FutureBuilder<List<TempatMakanModel>>(
        future: _myTempatMakanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text("Gagal memuat: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_mall_directory_outlined,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Anda belum mendaftarkan warung.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final listWarung = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _fetchData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: listWarung.length,
              itemBuilder: (context, index) {
                final item = listWarung[index];
                return Card(
                  elevation: 3,
                  margin: const EdgeInsets.only(bottom: 16),
                  clipBehavior: Clip.antiAlias, // Biar rapi pas diklik
                  child: InkWell(
                    // --- BISA DIKLIK UNTUK UPLOAD FOTO ---
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
                        // Placeholder Hijau (Bisa diganti foto asli nanti lewat backend kalau mau)
                        Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(color: Colors.green[200]),
                          child: const Icon(
                            Icons.storefront,
                            size: 50,
                            color: Colors.white,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 20,
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
                                  Text(
                                    " ${item.rating.toStringAsFixed(1)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item.address,
                                style: const TextStyle(color: Colors.grey),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const Divider(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () =>
                                        _konfirmasiHapus(item.id, item.name),
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 18,
                                    ),
                                    label: const Text(
                                      "Hapus",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Colors.red),
                                    ),
                                  ),
                                  const SizedBox(width: 8),

                                  // --- TOMBOL EDIT SUDAH BERFUNGSI ---
                                  ElevatedButton.icon(
                                    onPressed: () async {
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => EditTempatMakanPage(
                                            tempatMakan: item,
                                          ),
                                        ),
                                      );
                                      if (result == true) _fetchData();
                                    },
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text("Edit"),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green[800],
                                      foregroundColor: Colors.white,
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
