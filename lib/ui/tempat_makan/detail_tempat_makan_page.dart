import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/tempat_makan_model.dart';
import '../../models/review_model.dart';
import '../../models/photo_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/review_service.dart';
import '../../services/photo_service.dart';
import '../../utils/constants.dart';
import '../../services/favorite_service.dart';

class DetailTempatMakanPage extends StatefulWidget {
  final TempatMakanModel tempatMakan;
  const DetailTempatMakanPage({super.key, required this.tempatMakan});

  @override
  State<DetailTempatMakanPage> createState() => _DetailTempatMakanPageState();
}

class _DetailTempatMakanPageState extends State<DetailTempatMakanPage> {
  late Future<List<ReviewModel>> _reviewsFuture;
  late Future<List<PhotoModel>> _photosFuture;
  UserModel? _currentUser;
  bool _isFavorite = false;
  bool _isLoadingFavorite = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _checkCurrentUser();
    _checkFavoriteStatus();
  }

  void _checkFavoriteStatus() async {
    final status = await FavoriteService().checkFavorite(widget.tempatMakan.id);
    if (mounted) setState(() => _isFavorite = status);
  }

  void _toggleFavorite() async {
    if (_isLoadingFavorite) return;
    setState(() => _isLoadingFavorite = true);
    try {
      final newStatus = await FavoriteService().toggleFavorite(
        widget.tempatMakan.id,
      );
      if (mounted) {
        setState(() => _isFavorite = newStatus);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus
                  ? "Ditambahkan ke Favorit ❤️"
                  : "Dihapus dari Favorit 💔",
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
    } finally {
      if (mounted) setState(() => _isLoadingFavorite = false);
    }
  }

  void _fetchData() {
    setState(() {
      _reviewsFuture = ReviewService().getReviews(widget.tempatMakan.id);
      _photosFuture = PhotoService().getPhotos(widget.tempatMakan.id);
    });
  }

  void _checkCurrentUser() async {
    final user = await AuthService().getCurrentUser();
    if (mounted) setState(() => _currentUser = user);
  }

  String _buildImageUrl(String imagePath) {
    String rootUrl = ApiConfig.baseUrl.replaceAll('/api', '');
    return '$rootUrl/storage/$imagePath';
  }

  // --- MODAL REVIEW + UPLOAD FOTO (Untuk User) ---
  // (Kodenya sama persis seperti sebelumnya, saya persingkat di sini agar muat)
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
                  const Text(
                    "Tulis Ulasan",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => IconButton(
                        icon: Icon(
                          index < selectedRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 40,
                        ),
                        onPressed: () =>
                            setModalState(() => selectedRating = index + 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: commentCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Bagaimana pengalaman Anda?",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 50,
                      );
                      if (pickedFile != null)
                        setModalState(
                          () => selectedImage = File(pickedFile.path),
                        );
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
                                imageFile: selectedImage,
                              );
                              if (mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Ulasan berhasil dikirim!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                _fetchData();
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

  // --- MODAL BALAS REVIEW (KHUSUS OWNER) ---
  void _showReplyModal(ReviewModel review) {
    final replyCtrl = TextEditingController(text: review.reply ?? '');
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
                  const Text(
                    "Balas Ulasan Pelanggan",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '"${review.comment}"',
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: replyCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Tulis balasan Anda sebagai Pemilik",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  isSubmitting
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          onPressed: () async {
                            if (replyCtrl.text.isEmpty) return;
                            setModalState(() => isSubmitting = true);
                            try {
                              await ReviewService().replyReview(
                                review.id,
                                replyCtrl.text.trim(),
                              );
                              if (mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Berhasil membalas ulasan!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                _fetchData();
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
                            "Kirim Balasan",
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
    // Cek apakah yang login adalah pemilik warung ini
    bool isOwnerOfThisPlace =
        _currentUser != null && _currentUser!.id == widget.tempatMakan.userId;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tempatMakan.name),
        backgroundColor: isOwnerOfThisPlace ? Colors.green[800] : Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- FOTO SAMPUL UTAMA (Dari Database) ---
            if (widget.tempatMakan.imagePath != null &&
                widget.tempatMakan.imagePath!.isNotEmpty)
              Image.network(
                _buildImageUrl(widget.tempatMakan.imagePath!),
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              )
            else
              Container(
                height: 220,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.storefront,
                  size: 80,
                  color: Colors.grey,
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

                  const Divider(height: 32, thickness: 1),

                  // --- GALERI FOTO ---
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
                      if (!isOwnerOfThisPlace) // Cuma User yang disuruh nambah review+foto galeri
                        TextButton.icon(
                          onPressed: _showAddReviewModal,
                          icon: const Icon(
                            Icons.add_a_photo,
                            color: Colors.orange,
                          ),
                          label: const Text(
                            "Tambah Foto",
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
                        return const Text("Belum ada foto galeri.");
                      return SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                _buildImageUrl(snapshot.data![index].imagePath),
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const Divider(height: 48, thickness: 1),

                  // --- SEKSI ULASAN ---
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
                      if (!isOwnerOfThisPlace &&
                          _currentUser?.role ==
                              'user') // Cuma User yang bisa ngasih review
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
                                        children: List.generate(
                                          5,
                                          (starIndex) => Icon(
                                            starIndex < review.rating
                                                ? Icons.star
                                                : Icons.star_border,
                                            size: 16,
                                            color: Colors.amber,
                                          ),
                                        ),
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

                                  // --- BALASAN DARI OWNER MUNCUL DI SINI ---
                                  if (review.reply != null &&
                                      review.reply!.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.green[50],
                                        border: Border(
                                          left: BorderSide(
                                            color: Colors.green[700]!,
                                            width: 4,
                                          ),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Balasan Pemilik:",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green[800],
                                              fontSize: 13,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            review.reply!,
                                            style: const TextStyle(
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  // --- TOMBOL BALAS (KHUSUS OWNER) ---
                                  if (isOwnerOfThisPlace) ...[
                                    const SizedBox(height: 8),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        onPressed: () =>
                                            _showReplyModal(review),
                                        icon: Icon(
                                          review.reply == null
                                              ? Icons.reply
                                              : Icons.edit,
                                          color: Colors.green[700],
                                          size: 18,
                                        ),
                                        label: Text(
                                          review.reply == null
                                              ? "Balas"
                                              : "Edit Balasan",
                                          style: TextStyle(
                                            color: Colors.green[700],
                                          ),
                                        ),
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
