import 'package:flutter/material.dart';
import '../../models/tempat_makan_model.dart';
import '../../models/riview_model.dart';
import '../../services/review_service.dart';

class DetailTempatMakanPage extends StatefulWidget {
  final TempatMakanModel tempatMakan;

  const DetailTempatMakanPage({super.key, required this.tempatMakan});

  @override
  State<DetailTempatMakanPage> createState() => _DetailTempatMakanPageState();
}

class _DetailTempatMakanPageState extends State<DetailTempatMakanPage> {
  late Future<List<ReviewModel>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  void _fetchReviews() {
    setState(() {
      _reviewsFuture = ReviewService().getReviews(widget.tempatMakan.id);
    });
  }

  // --- POP-UP MODAL TAMBAH REVIEW ---
  void _showAddReviewModal() {
    int selectedRating = 5;
    final commentCtrl = TextEditingController();
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
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
                  const Text(
                    "Beri Penilaian",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Bintang Rating (Custom)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                        onPressed: () {
                          setModalState(() => selectedRating = index + 1);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: commentCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Tulis ulasan Anda (Opsional)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  isSubmitting
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () async {
                            setModalState(() => isSubmitting = true);
                            try {
                              await ReviewService().addReview(
                                widget.tempatMakan.id,
                                selectedRating,
                                commentCtrl.text.trim(),
                              );
                              if (mounted) {
                                Navigator.pop(ctx); // Tutup modal
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Review berhasil dikirim!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                _fetchReviews(); // Refresh daftar review
                              }
                            } catch (e) {
                              if (mounted) {
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
                              }
                            } finally {
                              if (mounted) {
                                setModalState(() => isSubmitting = false);
                              }
                            }
                          },
                          child: const Text(
                            "Kirim Review",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
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
        title: Text(widget.tempatMakan.name),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      // Gunakan floatingActionButton untuk tombol tambah review agar mudah diakses
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReviewModal,
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.rate_review, color: Colors.white),
        label: const Text("Beri Ulasan", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Gambar Placeholder
            Container(
              height: 200,
              color: Colors.orange[200],
              child: const Icon(
                Icons.restaurant,
                size: 80,
                color: Colors.white,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.tempatMakan.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 28),
                          Text(
                            widget.tempatMakan.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.tempatMakan.address,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32, thickness: 1),
                  const Text(
                    "Tentang Tempat Ini",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.tempatMakan.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),

                  const Divider(height: 48, thickness: 1),
                  const Text(
                    "Ulasan Pengunjung",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // --- AREA DAFTAR REVIEW ---
                  FutureBuilder<List<ReviewModel>>(
                    future: _reviewsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text("Gagal memuat ulasan: ${snapshot.error}");
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              "Belum ada ulasan. Jadilah yang pertama!",
                            ),
                          ),
                        );
                      }

                      final listReview = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap:
                            true, // Wajib agar tidak error dalam SingleChildScrollView
                        physics:
                            const NeverScrollableScrollPhysics(), // Scroll mengikuti SingleChildScrollView induk
                        itemCount: listReview.length,
                        itemBuilder: (context, index) {
                          final review = listReview[index];
                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        review.userName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Row(
                                        children: List.generate(5, (starIndex) {
                                          return Icon(
                                            starIndex < review.rating
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 16,
                                            color: Colors.amber,
                                          );
                                        }),
                                      ),
                                    ],
                                  ),
                                  if (review.comment.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      review.comment,
                                      style: const TextStyle(
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    height: 80,
                  ), // Jarak ekstra di bawah biar gak ketutup tombol Floating
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
