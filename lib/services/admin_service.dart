import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pengajuan_owner_model.dart';
import '../utils/constants.dart';

class AdminService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- 1. Ambil daftar pengajuan (PENDING) ---
  Future<List<PengajuanOwnerModel>> getPendingPengajuan() async {
    String? token = await _getToken();
    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/admin/pengajuan'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data.map((item) => PengajuanOwnerModel.fromJson(item)).toList();
      } else {
        throw Exception('Gagal memuat daftar pengajuan');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan jaringan atau server: $e');
    }
  }

  // --- 2. Setujui Pengajuan (ACC) ---
  Future<void> approvePengajuan(int id) async {
    String? token = await _getToken();
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/admin/pengajuan/$id/approve'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Gagal menyetujui pengajuan');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // --- 3. Tolak Pengajuan ---
  Future<void> rejectPengajuan(int id) async {
    String? token = await _getToken();
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/admin/pengajuan/$id/reject'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Gagal menolak pengajuan');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
