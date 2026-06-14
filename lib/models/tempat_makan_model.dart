class TempatMakanModel {
  final int id;
  final int userId;
  final String name;
  final String description;
  final String address;
  final double rating;
  final String? imagePath;

  TempatMakanModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.address,
    required this.rating,
    this.imagePath,
  });

  factory TempatMakanModel.fromJson(Map<String, dynamic> json) {
    return TempatMakanModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      imagePath: json['image_path'], // <-- TAMBAHKAN BARIS INI
    );
  }
}
