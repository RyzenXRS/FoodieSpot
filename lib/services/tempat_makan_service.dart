import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/tempat_makan_model.dart';
import '../utils/constants.dart';

class TempatMakanService {
  // Helper internal untuk mengambil token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // --- 1. AMBIL DAFTAR TEMPAT MAKAN (READ) ---
  Future<List<TempatMakanModel>> getTempatMakan() async {
    String? token = await _getToken();

    try {
      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/tempat-makan'),
            headers: {
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body)['data'] as List;
        return data.map((item) => TempatMakanModel.fromJson(item)).toList();
      } else {
        throw Exception(
          json.decode(response.body)['message'] ?? 'Gagal memuat data',
        );
      }
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }

  // --- 2. TAMBAH TEMPAT MAKAN BARU (CREATE) ---
  Future<void> addTempatMakan({
    required String name,
    required String desc,
    required String address,
  }) async {
    String? token = await _getToken();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/tempat-makan'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {'name': name, 'description': desc, 'address': address},
      );

      if (response.statusCode != 201) {
        throw Exception(
          json.decode(response.body)['message'] ?? 'Gagal menambahkan data',
        );
      }
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }

  // --- 3. EDIT TEMPAT MAKAN (UPDATE) ---
  Future<void> updateTempatMakan({
    required int id,
    required String name,
    required String desc,
    required String address,
  }) async {
    String? token = await _getToken();

    try {
      final response = await http.put(
        Uri.parse(
          '${ApiConfig.baseUrl}/tempat-makan/$id',
        ), // Perhatikan ada tambahan ID di URL
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: {'name': name, 'description': desc, 'address': address},
      );

      if (response.statusCode != 200) {
        throw Exception(
          json.decode(response.body)['message'] ?? 'Gagal mengedit data',
        );
      }
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }

  // --- 4. HAPUS TEMPAT MAKAN (DELETE) ---
  Future<void> deleteTempatMakan(int id) async {
    String? token = await _getToken();

    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/tempat-makan/$id'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        throw Exception(
          json.decode(response.body)['message'] ?? 'Gagal menghapus data',
        );
      }
    } catch (e) {
      throw Exception('Kesalahan jaringan: $e');
    }
  }
}
