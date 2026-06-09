class ReviewModel {
  final int id;
  final int userId;
  final int tempatMakanId;
  final int rating;
  final String comment;
  final String userName; // Nama user yang mereview (dari relasi)

  ReviewModel({
    required this.id,
    required this.userId,
    required this.tempatMakanId,
    required this.rating,
    required this.comment,
    required this.userName,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      tempatMakanId: json['tempat_makan_id'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      // Mengambil nama dari objek relasi 'user' jika ada
      userName: json['user'] != null
          ? json['user']['name']
          : 'User Tidak Diketahui',
    );
  }
}
