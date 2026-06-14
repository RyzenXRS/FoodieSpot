class ReviewModel {
  final int id;
  final int userId;
  final int tempatMakanId;
  final int rating;
  final String comment;
  final String userName;
  final String? imagePath;
  final String? reply; // <-- TAMBAHAN

  ReviewModel({
    required this.id,
    required this.userId,
    required this.tempatMakanId,
    required this.rating,
    required this.comment,
    required this.userName,
    this.imagePath,
    this.reply, // <-- TAMBAHAN
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      tempatMakanId: json['tempat_makan_id'] ?? 0,
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      userName: json['user'] != null ? json['user']['name'] : 'User',
      imagePath: json['image_path'],
      reply: json['reply'],
    );
  }
}
