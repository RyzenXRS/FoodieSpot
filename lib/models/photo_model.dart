class PhotoModel {
  final int id;
  final int userId;
  final int tempatMakanId;
  final String imagePath;
  final String uploaderName;

  PhotoModel({
    required this.id,
    required this.userId,
    required this.tempatMakanId,
    required this.imagePath,
    required this.uploaderName,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    return PhotoModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      tempatMakanId: json['tempat_makan_id'] ?? 0,
      imagePath: json['image_path'] ?? '',
      uploaderName: json['user'] != null ? json['user']['name'] : 'User',
    );
  }
}
