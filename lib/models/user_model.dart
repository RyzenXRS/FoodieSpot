class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String photoUrl;
  final bool isSuspended;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone = '',
    this.photoUrl = '',
    this.isSuspended = false,
  });

  // Convert dari JSON Laravel ke Objek Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'user',
      phone: json['phone'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      // Laravel mengembalikan boolean asli karena sudah kita cast di model User.php
      isSuspended: json['is_suspended'] ?? false,
    );
  }
}
