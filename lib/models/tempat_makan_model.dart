class TempatMakanModel {
  final int id;
  final int userId;
  final String name;
  final String description;
  final String address;
  final double rating;
  final double? latitude;
  final double? longitude;
  final String? imageUrl; // Full URL dari backend (sudah include http://...)
  final String? mapsUrl;  // Google Maps navigation URL

  TempatMakanModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.address,
    required this.rating,
    this.latitude,
    this.longitude,
    this.imageUrl,
    this.mapsUrl,
  });

  factory TempatMakanModel.fromJson(Map<String, dynamic> json) {
    return TempatMakanModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
      // Backend sudah return full URL, langsung pakai
      imageUrl: json['image_url'],
      mapsUrl: json['maps_url'],
    );
  }
}
