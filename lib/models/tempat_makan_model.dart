class TempatMakanModel {
  final int id;
  final int userId;
  final String name;
  final String description;
  final String address;
  final double latitude;
  final double longitude;
  final String imageUrl;
  final double rating;

  TempatMakanModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.address,
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.imageUrl = '',
    this.rating = 0.0,
  });

  factory TempatMakanModel.fromJson(Map<String, dynamic> json) {
    return TempatMakanModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      // Konversi aman ke double jika Laravel mengirimkan integer (misal: 0 alih-alih 0.0)
      latitude: double.tryParse(json['latitude']?.toString() ?? '0') ?? 0.0,
      longitude: double.tryParse(json['longitude']?.toString() ?? '0') ?? 0.0,
      imageUrl: json['image_url'] ?? '',
      rating: double.tryParse(json['rating']?.toString() ?? '0') ?? 0.0,
    );
  }
}
