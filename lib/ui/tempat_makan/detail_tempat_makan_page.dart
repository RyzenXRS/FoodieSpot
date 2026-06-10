import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/tempat_makan_model.dart';
import '../../models/review_model.dart';
import '../../models/photo_model.dart';
import '../../services/review_service.dart';
import '../../services/photo_service.dart';
import '../../utils/constants.dart';

class DetailTempatMakanPage extends StatefulWidget {
  final TempatMakanModel tempatMakan;
  const DetailTempatMakanPage({super.key, required this.tempatMakan});

  @override
  State<DetailTempatMakanPage> createState() => _DetailTempatMakanPageState();
}

class _DetailTempatMakanPageState extends State<DetailTempatMakanPage> {
  late Future<List<ReviewModel>> _reviewsFuture;
  late Future<List<PhotoModel>> _photosFuture;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _reviewsFuture = ReviewService().getReviews(widget.tempatMakan.id);
      _photosFuture = PhotoService().getPhotos(widget.tempatMakan.id);
    });
  }

  // --- MODAL REVIEW + UPLOAD FOTO ---
  void _showAddReviewModal() {
    int selectedRating = 5;
    final commentCtrl = TextEditingController();
    File? selectedImage;
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
                    "Tulis Ulasan",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Bintang
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
                        onPressed: () =>
                            setModalState(() => selectedRating = index + 1),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),

                  // Form Komentar
                  TextField(
                    controller: commentCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Bagaimana pengalaman Anda?",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // --- KOTAK PEMILIH FOTO ---
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 70,
                      );
                      if (pickedFile != null) {
                        setModalState(
                          () => selectedImage = File(pickedFile.path),
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
                      child: selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                selectedImage!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Tambahkan Foto (Opsional)",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Tombol Kirim
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
                                imageFile: selectedImage, // Kirim foto jika ada
                              );
                              if (mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Ulasan berhasil dikirim!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                _fetchData(); // Refresh UI Review dan Galeri sekaligus!
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
                              if (mounted)
                                setModalState(() => isSubmitting = false);
                            }
                          },
                          child: const Text(
                            "Kirim Ulasan",
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

  String _buildImageUrl(String imagePath) {
    String rootUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    return '$rootUrl/storage/$imagePath';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tempatMakan.name),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<List<PhotoModel>>(
              future: _photosFuture,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return Image.network(
                    _buildImageUrl(snapshot.data!.first.imagePath),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  );
                }
                return Container(
                  height: 200,
                  color: Colors.orange[200],
                  child: const Icon(
                    Icons.restaurant,
                    size: 80,
                    color: Colors.white,
                  ),
                );
              },
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

                  const Divider(height: 32, thickness: 1),

                  // --- SEKSI GALERI FOTO ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Galeri Foto",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Tombol Tambah Galeri sekarang langsung memanggil modal review
                      TextButton.icon(
                        onPressed: _showAddReviewModal,
                        icon: const Icon(
                          Icons.rate_review,
                          color: Colors.orange,
                        ),
                        label: const Text(
                          "Tulis Ulasan & Foto",
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  FutureBuilder<List<PhotoModel>>(
                    future: _photosFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return const Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData || snapshot.data!.isEmpty)
                        return const Text("Belum ada foto.");

                      return SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _buildImageUrl(
                                    snapshot.data![index].imagePath,
                                  ),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  const Divider(height: 48, thickness: 1),

                  // --- SEKSI ULASAN (DENGAN GAMBAR) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Ulasan Pengunjung",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _showAddReviewModal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Beri Ulasan"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  FutureBuilder<List<ReviewModel>>(
                    future: _reviewsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting)
                        return const Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData || snapshot.data!.isEmpty)
                        return const Center(child: Text("Belum ada ulasan."));

                      final listReview = snapshot.data!;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: listReview.length,
                        itemBuilder: (context, index) {
                          final review = listReview[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 16),
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
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],

                                  // --- MUNCULKAN FOTO DI DALAM REVIEW JIKA ADA ---
                                  if (review.imagePath != null &&
                                      review.imagePath!.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        _buildImageUrl(review.imagePath!),
                                        height: 150,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
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
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
