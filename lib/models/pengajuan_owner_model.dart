class PengajuanOwnerModel {
  final int id;
  final int userId;
  final String namaToko;
  final String deskripsiToko;
  final String status;

  PengajuanOwnerModel({
    required this.id,
    required this.userId,
    required this.namaToko,
    required this.deskripsiToko,
    required this.status,
  });

  factory PengajuanOwnerModel.fromJson(Map<String, dynamic> json) {
    return PengajuanOwnerModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      namaToko: json['nama_toko'] ?? '',
      deskripsiToko: json['deskripsi_toko'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }
}
