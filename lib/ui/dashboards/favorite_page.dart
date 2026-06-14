import 'package:flutter/material.dart';
import '../../services/favorite_service.dart';
import '../../models/tempat_makan_model.dart';
import '../tempat_makan/detail_tempat_makan_page.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  late Future<List<TempatMakanModel>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _favoritesFuture = FavoriteService().getFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tersimpan"),
        backgroundColor: Colors.pink, // Warna pink khusus halaman Favorit
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<TempatMakanModel>>(
        future: _favoritesFuture,
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
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Belum ada warung favorit.",
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
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.pink[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.fastfood, color: Colors.pink),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            Text(" ${item.rating.toStringAsFixed(1)}"),
                          ],
                        ),
                        Text(
                          item.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.favorite, color: Colors.pink),
                    onTap: () async {
                      // Saat kembali dari detail, refresh daftar (siapa tahu favoritenya di-unlove)
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DetailTempatMakanPage(tempatMakan: item),
                        ),
                      );
                      _fetchData();
                    },
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
